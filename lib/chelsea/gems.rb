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
      unless File.file?(file) || file.nil?
        raise 'Gemfile.lock not found, check --file path'
      end

      _silence_stderr if @quiet

      @pastel = Pastel.new
      @formatter = FormatterFactory.new.get_formatter(
        format: options[:format],
        quiet: @quiet)
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
      if @deps.dependencies.nil?
        _print_err 'No dependencies retrieved. Exiting.'
        return
      end
      if server_response.nil?
        _print_err 'No vulnerability data retrieved from server. Exiting.'
        return
      end
      results = @formatter.get_results(server_response, @deps.reverse_dependencies)
      @formatter.do_print(results)

      server_response.map { |r| r['vulnerabilities'].length.positive? }.any?
    end

    def collect_iq
      @deps.dependencies
    end

    protected

    def _silence_stderr
      $stderr.reopen('/dev/null', 'w')
    end

    def _print_err(s)
      puts @pastel.red.bold(s)
    end

    def _print_success(s)
      puts @pastel.green.bold(s)
    end
  end
end
