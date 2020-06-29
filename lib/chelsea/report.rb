#
# Copyright 2019-Present Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# frozen_string_literal: true
require 'pastel'
require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'

require_relative 'version'
require_relative 'formatters/factory'
require_relative 'lockfile'
require_relative 'bom'
require_relative 'spinner'

module Chelsea
  # Class to collect and audit packages from a Gemfile.lock
  # Pastel / Spinner which has some sketchy use.
  # Client for calling OSSIndex
  # Lockfile parses lockfile, provides access to dependencies
  # Response for collecting response from OSS
  class Report
    attr_accessor :lockfile
    def initialize(file:, verbose: false, options: { 'format': 'text' })
      @verbose = verbose
      unless File.file?(file) || file.nil?
        raise 'Gemfile.lock not found, check --file path'
      end

      _silence_stderr unless @verbose

      @pastel = Pastel.new
      @formatter = FormatterFactory.new.get_formatter(
        format: options[:format],
        verbose: verbose
      )
      @client = Chelsea.client(options)
      @lockfile = Chelsea::Lockfile.new(path: Pathname.new(file))
      @spinner = Chelsea::Spinner.new
    end

    # Audits depenencies using lockfile library and prints results
    # using formatter library

    def generate
      dependencies = _parse_dependencies
      oi_response = _get_vulns
      if dependencies.nil?
        _print_err 'No dependencies read. Exiting.'
        return
      end
      if oi_response.json.nil?
        _print_success 'No vulnerability data retrieved from server. Exiting.'
        return
      end
      @formatter.oi_response = oi_response
      @formatter.reverse_dependencies = reverse_dependencies
      @formatter.do_print
      oi_response.vuln_count.positive?
    end

    protected

    def _get_vulns
      spin = @spinner.spin_msg 'Making request to OSS Index server'
      begin
        server_response = @client.get_vulns(_parse_versions)
        spin.success('...done.')
      rescue SocketError => _e
        spin.stop('...request failed.')
        _print_err 'Socket error getting data from OSS Index server.'
      rescue RestClient::RequestFailed => e
        spin.stop('...request failed.')
        _print_err "Error getting data from OSS Index server:#{e.response}."
      rescue RestClient::ResourceNotFound => _e
        spin.stop('...request failed.')
        _print_err 'Error getting data from OSS Index server. Resource not found.'
      rescue Errno::ECONNREFUSED => _e
        spin.stop('...request failed.')
        _print_err 'Error getting data from OSS Index server. Connection refused.'
      end
      server_response
    end

    def _parse_versions
      spin = @spinner.spin_msg 'Parsing Versions'
      coordinates = @lockfile.coordinates
      spin.success('...done.')
      coordinates
    end

    def _parse_dependencies
      spin = @spinner.spin_msg 'Parsing dependencies'
      begin
        # maybe don't init deps until here
        # A lot of this design was with the intention of minimizing this access.
        # Avoiding I/O, in this case, the reading of a file.
        dependencies = @lockfile.dependencies
        spin.success('...done.')
      rescue StandardError => _e
        # Test throwing this exceptions
        spin.stop
        _print_err "Parsing dependency line #{gem} failed."
      end
      dependencies
    end

    # Collects all reverse dependencies from dependencies lockfile
    def reverse_dependencies
      reverse_command = Gem::Commands::DependencyCommand.new
      reverse_command.options[:reverse_dependencies] = true
      # We want to filter the reverses dependencies by specs in lockfile
      reverse_command
        .reverse_dependencies(@lockfile.file.specs)
        .to_h
        .transform_values! do |reverse_dep|
          reverse_dep.select do |name, _dep, _req, _|
            @lockfile.spec_names.include?(name.split('-')[0])
          end
        end
    end

    def _silence_stderr
      $stderr.reopen('/dev/null', 'w')
    end

    def _print_err(msg)
      puts @pastel.red.bold(msg)
    end

    def _print_success(msg)
      puts @pastel.green.bold(msg)
    end
  end
end
