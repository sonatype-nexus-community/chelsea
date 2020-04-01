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
      @reverese_deps = @deps.to_h(reverse: true)
    end

    def execute(input: $stdin, output: $stdout) 
      if @deps.nil?
        print_err "No dependencies retrieved. Exiting."
        return
      end
      if !@deps.server_response.count
        print_err "No vulnerability data retrieved from server. Exiting."
        return
      end
      print_result = @formatter.get_results(@deps)
      @formatter.do_print(print_result)
    end

    protected

    def print_results
      response = String.new
      response += "\n"\
                  "Audit Results\n"\
                  "=============\n"
      i = 0
      count = @deps.server_response.count()

      @deps.server_response.each do |r|
        i += 1
        package = r["coordinates"]
        vulnerable = r["vulnerabilities"].length() > 0
        coord = r["coordinates"].sub("pkg:gem/", "")
        name = coord.split('@')[0]
        version = coord.split('@')[1]
        reverse_dep_coord = "#{name}-#{version}"
        if vulnerable
          response += @pastel.red("[#{i}/#{count}] - #{package} ") +  @pastel.red.bold("Vulnerable.\n")
          response += print_reverse_deps(reverse_dep_coord, name)
          r["vulnerabilities"].each do |k, v|
            response += @pastel.red.bold("    #{k}:#{v}")
          end
        else
          response += @pastel.white("[#{i}/#{count}] - #{package} ") + @pastel.green.bold("No vulnerabilities found!\n")
          response += print_reverse_deps(reverse_dep_coord, name)
        end
      end

      response
    end


    def print_err(s)
      puts @pastel.red.bold(s)
    end

    def print_success(s)
      puts @pastel.green.bold(s)
    end

    def _gemfile_lock_file_exists?
      ::File.file? @file
    end
  end
end