# frozen_string_literal: true
require 'pastel'
require 'tty-spinner'
require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'

require_relative 'version'
require_relative 'formatters/factory'
require_relative 'deps'
require_relative 'bom'

module Chelsea
  class Gems
    def initialize(file:, quiet: false, options: {})
      @quiet = quiet
      unless File.file?(file) || file.nil?
        raise 'Gemfile.lock not found, check --file path'
      end

      @pastel = Pastel.new
      @formatter = FormatterFactory.new.get_formatter(format: options[:format])
      @client = Chelsea.client(options)
      @deps = Chelsea::Deps.new(path: Pathname.new(file))
    end

    # Audits depenencies using deps library and prints results
    # using formatter library

    def execute
      server_response, dependencies, reverse_dependencies = audit
      if dependencies.nil?
        _print_err 'No dependencies retrieved. Exiting.'
        return
      end
      if server_response.nil?
        _print_err 'No vulnerability data retrieved from server. Exiting.'
        return
      end
      results = @formatter.get_results(server_response, reverse_dependencies)
      @formatter.do_print(results)
    end

    # Runs through auditing algorithm, raising exceptions
    # on REST calls made by @deps.get_vulns
    def audit
      # This spinner management is out of control
      # we should wrap a block with start and stop messages,
      # or use a stack to ensure all spinners stop.
      unless @quiet
        spinner = _spin_msg "Parsing dependencies"
      end

      begin
        dependencies = @deps.dependencies
        unless @quiet
          spinner.success("...done.")
        end
      rescue StandardError => e
        unless @quiet
          spinner.stop
        end
        _print_err "Parsing dependency line #{gem} failed."
      end

      reverse_dependencies = @deps.reverse_dependencies

      unless @quiet
        spinner = _spin_msg "Parsing Versions"
      end
      coordinates = @deps.coordinates
      unless @quiet
        spinner.success("...done.")
      end

      unless @quiet
        spinner = _spin_msg "Making request to OSS Index server"
      end

      begin
        server_response = @client.get_vulns(coordinates)
        unless @quiet
          spinner.success("...done.")
        end
      rescue SocketError => e
        unless @quiet
          spinner.stop("...request failed.")
        end
        _print_err "Socket error getting data from OSS Index server."
      rescue RestClient::RequestFailed => e
        unless @quiet
          spinner.stop("...request failed.")
        end
        _print_err "Error getting data from OSS Index server:#{e.response}."
      rescue RestClient::ResourceNotFound => e
        unless @quiet
          spinner.stop("...request failed.")
        end
        _print_err "Error getting data from OSS Index server. Resource not found."
      rescue Errno::ECONNREFUSED => e
        unless @quiet
          spinner.stop("...request failed.")
        end
        _print_err "Error getting data from OSS Index server. Connection refused."
      rescue StandardError => e
        unless @quiet
          spinner.stop("...request failed.")
        end
        _print_err "UNKNOWN Error getting data from OSS Index server."
      end
      [server_response, dependencies, reverse_dependencies]
    end

    protected

    def _spin_msg(msg)
      format = "[#{@pastel.green(':spinner')}] " + @pastel.white(msg)
      spinner = TTY::Spinner.new(
        format,
        success_mark: @pastel.green('+'),
        hide_cursor: true
      )
      spinner.auto_spin
      spinner
    end

    def _print_err(s)
      puts @pastel.red.bold(s)
    end

    def _print_success(s)
      puts @pastel.green.bold(s)
    end
  end
end
