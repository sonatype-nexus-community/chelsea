# frozen_string_literal: true
require 'pastel'
require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'

require_relative 'version'
require_relative 'formatters/factory'
require_relative 'deps'
require_relative 'bom'
require_relative 'spinner'

module Chelsea
  # Class to collect and audit packages from a Gemfile.lock
  class Gems
    attr_accessor :deps
    def initialize(file:, quiet: false, options: { 'format': 'text' })
      @quiet = quiet
      @format = options[:format]
      unless File.file?(file) || file.nil?
        raise 'Gemfile.lock not found, check --file path'
      end

      _silence_stderr if @quiet

      @pastel = Pastel.new

      @client = Chelsea.client(options)
      @deps = Chelsea::Deps.new(path: Pathname.new(file))
      @spinner = Chelsea::Spinner.new
    end

    # Audits depenencies using deps library and prints results
    # using formatter library
    # Runs through auditing algorithm, raising exceptions
    # on REST calls made by @deps.get_vulns
    def execute
      server_response = @client.get_vulns(@deps.coordinates)
      # if @deps.dependencies.nil? # Should be exceptions
      #   p _err 'No dependencies retrieved. Exiting.'
      #   return
      # end
      # if server_response.nil? #Should be exception
      #   p _err 'No vulnerability data retrieved from server. Exiting.'
      #   return
      # end
      @formatter = FormatterFactory.new.get_formatter(
        format: @format,
        quiet: @quiet,
        server_response: server_response,
        reverse_dependencies: @deps.reverse_dependencies
      )
      @formatter.do_print

      server_response.map { |r| r['vulnerabilities'].length.positive? }.any?
    end

    def collect_iq
      @deps.dependencies
    end

    protected

    def _silence_stderr
      $stderr.reopen('/dev/null', 'w')
    end

    def _err(msg)
      @pastel.red.bold(msg)
    end

    def _success(msg)
      @pastel.green.bold(msg)
    end
  end
end
