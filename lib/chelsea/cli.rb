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

require 'slop'
require 'pastel'
require 'tty-font'

require_relative 'version'
require_relative 'report'
require_relative 'iq_client'
require_relative 'config'

module Chelsea
  ##
  # This class provides an interface to the oss index, gems and lockfile
  class CLI
    def initialize(opts)
      @opts = opts
      @pastel = Pastel.new
      _validate_arguments
      _show_logo # Move to formatter
    end

    def process!
      if @opts.config?
        _set_config # move to init
      elsif @opts.clear?
        require_relative 'db'
        # Class Method?
        Chelsea::DB.new().clear_cache
        puts 'OSS Index cache cleared'
      elsif @opts.file? && @opts.iq?
        report = _process_file
        _submit_sbom(report.dependencies)
      elsif @opts.file?
        _process_file
      elsif @opts.help? # quit on opts.help earlier
        puts _cli_flags # this doesn't exist
      end
    end

    def self.version
      Chelsea::VERSION
    end

    private

    def _submit_sbom(report)
      iq = Chelsea::IQClient.new(
        options: {
          public_application_id: @opts[:application],
          server_url: @opts[:server],
          username: @opts[:iquser],
          auth_token: @opts[:iqpass]
        }
      )
      bom = Chelsea::Bom.new(report.lockfile.dependencies).collect

      status_url = iq.post_sbom(bom)
      return unless status_url

      iq.poll_status(status_url)
    end

    def _process_file
      report = Chelsea::Report.new(
        file: @opts[:file],
        verbose: @opts[:verbose],
        options: @opts
      )
      report.execute ? (exit 1) : (exit 0)
    end

    def _process_file_iq
      Chelsea::Report.new(
        file: @opts[:file],
        verbose: @opts[:verbose],
        options: @opts
      )
    end

    def _flags_error
      switches = _flags.collect { |f| "--#{f}" }
      abort "please set one of #{switches}"
    end

    def _validate_arguments
      return unless !_flags_set? && !@opts.file?

      _flags_error
    end

    def _flags_set?
      # I'm still unsure what this is trying to express
      valid_flags = _flags.collect {|arg| @opts[arg] }.compact
      valid_flags.count > 1
    end

    def _flags
      # Seems wrong, should all be handled by bin
      %i[file help config]
    end

    def _show_logo
      font = TTY::Font.new(:doom)
      puts @pastel.green(font.write('Chelsea'))
      puts @pastel.green('Version: ' + CLI.version)
    end

    def _load_config
      config = Chelsea::Config.new
      config.oss_index_config
    end

    def _set_config
      Chelsea.read_oss_index_config_from_command_line
    end
  end
end
