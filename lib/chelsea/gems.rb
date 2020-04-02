# frozen_string_literal: true

require 'pastel'
require 'tty-spinner'
require_relative 'oss_index'
require_relative 'deps'
require 'bundler'
require 'bundler/lockfile_parser'
require_relative 'version'
require_relative 'formatters/factory'
require 'rubygems'
require 'rubygems/commands/dependency_command'

module Chelsea
  class Gems
    def initialize(file:, quiet: false, options: {})
      @file, @quiet, @options = file, quiet, options

      if not _gemfile_lock_file_exists? or file.nil?
        raise "Gemfile.lock not found, check --file path"
      end
      @pastel = Pastel.new
      @formatter = FormatterFactory.new.get_formatter(@options)
      @deps = Chelsea::Deps.new({path: Pathname.new(@file)})
    end

    def execute(input: $stdin, output: $stdout) 
      audit
      if @deps.nil?
        _print_err "No dependencies retrieved. Exiting."
        return
      end
      if !@deps.server_response.count
        _print_err "No vulnerability data retrieved from server. Exiting."
        return
      end
      @formatter.do_print(@formatter.get_results(@deps))
    end

    def audit
      if !@quiet
        spinner = _spin_msg "Parsing dependencies"
      end

      begin
        @deps.get_dependencies
      rescue StandardError => e
        if !@quiet
          spinner.stop
        end
        _print_err "Parsing dependency line #{gem} failed."
      end

      @deps.get_reverse_dependencies

      if !@quiet
        spinner = _spin_msg "Parsing Versions"
      end
      @deps.get_dependencies_versions_as_coordinates
      if !@quiet
        spinner.success("...done.")
      end

      if !@quiet
        spinner = _spin_msg "Making request to OSS Index server"
      end

      begin
        @deps.get_vulns
      rescue SocketError => e
        if !@quiet
          spinner.stop("...request failed.")
        end
        _print_err "Socket error getting data from OSS Index server."
      rescue RestClient::RequestFailed => e
        if !@quiet
          spinner.stop("...request failed.")
        end
        _print_err "Error getting data from OSS Index server:#{e.response}."
      rescue RestClient::ResourceNotfound => e
        if !@quiet
          spinner.stop("...request failed.")
        end
        _print_err "Error getting data from OSS Index server. Resource not found."
      rescue Errno::ECONNREFUSED => e
        if !@quiet
          spinner.stop("...request failed.")
        end
        _print_err "Error getting data from OSS Index server. Connection refused."
      rescue StandardError => e
        if !@quiet
          spinner.stop("...request failed.")
        end
        _print_err "UNKNOWN Error getting data from OSS Index server."
      end
    end

    protected
    def _spin_msg(msg)
      format = "[#{@pastel.green(':spinner')}] " + @pastel.white(msg)
      spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
      spinner.auto_spin()
      spinner
    end

    def _print_err(s)
      puts @pastel.red.bold(s)
    end

    def _print_success(s)
      puts @pastel.green.bold(s)
    end

    def _gemfile_lock_file_exists?
      ::File.file? @file
    end
  end
end