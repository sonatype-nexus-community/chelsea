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
      @reverse_deps = @deps.to_h(reverse: true)
    end

    def execute(input: $stdin, output: $stdout) 
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

    protected

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