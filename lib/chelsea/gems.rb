# frozen_string_literal: true

require 'pastel'
require 'tty-spinner'
require_relative 'oss_index'
require_relative 'deps'
require 'bundler'
require 'bundler/lockfile_parser'
require_relative 'version'
require_relative 'formatters/json'
require_relative 'formatters/text'
require_relative 'formatters/xml'
require 'rubygems'
require 'rubygems/commands/dependency_command'
require 'pstore'

module Chelsea
  class Gems
    def initialize(file)
      @file = file
      if not _gemfile_lock_file_exists?
        raise "Gemfile.lock not found, check --file path"
      end
      @options = options
      @pastel = Pastel.new
      @dependencies = Hash.new()
      @dependencies_versions = Hash.new()
      @coordinates = Hash.new()
      @coordinates["coordinates"] = Array.new()
      @server_response = Array.new()
      @reverse_deps = Hash.new()
      @store = PStore.new(get_db_store_location())
      case @options[:format]
      when 'text'
        @formatter = Chelsea::TextFormatter.new(options)
      when 'json'
        @formatter = Chelsea::JsonFormatter.new(options)
      when 'xml'
        @formatter = Chelsea::XMLFormatter.new(options)
      else
        @formatter = Chelsea::TextFormatter.new(options)
      end

      @pastel = Pastel.new
      @deps = Chelsea::Deps.new({path: Pathname.new(@file)})
      @ossindex = Chelsea::OssIndex.new({})

    end

    def execute(input: $stdin, output: $stdout) 
      n = get_dependencies()
      if n == 0
        print_err "No dependencies retrieved. Exiting."
        return
      end
      get_dependencies_versions()
      get_coordinates()
      n = get_vulns()
      if n == 0
        print_err "No vulnerability data retrieved from server. Exiting."
        return
      end
      print_result = @formatter.get_results(@server_response, @reverse_deps)
      @formatter.do_print(print_result)
    end

    def get_dependencies()
      if !@options[:quiet]
        format = "[#{@pastel.green(':spinner')}] " + @pastel.white("Parsing dependencies")
        spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
        spinner.auto_spin()
      end

      reverse = Gem::Commands::DependencyCommand.new
      reverse.options[:reverse_dependencies] = true
      @reverse_deps = reverse.reverse_dependencies(@lockfile.specs)

      @lockfile.specs.each do |gem|
        @dependencies[gem.name] = [gem.name, gem.version]
        rescue StandardError => e
          if !@options[:quiet] then spinner.stop("...failed.") end
          print_err "Parsing dependency line #{gem} failed."
      end

      c = @dependencies.count()
      if !@options[:quiet] then spinner.success("...done. Parsed #{c} dependencies.") end
      c
    end

    def get_dependencies_versions()
      if !@options[:quiet]
        format = "[#{@pastel.green(':spinner')}] " + @pastel.white("Parsing versions")
        spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
        spinner.auto_spin()
      end
      @dependencies.each do |p, r|
        o =  r[0]
        v = r[1].to_s
        if v.split('.').length == 1 then
          v = v + ".0.0"
        elsif v.split('.').length == 2 then
            v = v + ".0"
        end
        @dependencies_versions[p] = v
      end
      c = @dependencies_versions.count()
      if !@options[:quiet]
        spinner.success("...done.")
      end
      c
    end

    private

    def _parse_deps
      spin("Parsing dependencies")
      @deps.to_h
      # spin.success("...done. Parsed #{dependencies.count()} dependencies.")
    end

    def get_vulns()
      require 'json'
      require 'rest-client'
      if !@options[:quiet]
        format = "[#{@pastel.green(':spinner')}] " + @pastel.white("Making request to OSS Index server")
        spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
        spinner.auto_spin()
      end
    end

    def _parse_reverse_deps
      @deps.to_h(reverse: true)
    end

    def _parse_versions(deps_hash)
      coordinates = Hash.new()
      Chelsea::Deps.to_coordinates(deps_hash)
    end

    def print_results(server_response, reverse_deps)
      puts ""
      puts "Audit Results"
      puts "============="

      if @coordinates["coordinates"].count() > 0
        chunked = Hash.new()
        @coordinates["coordinates"].each_slice(128).to_a.each do |coords|
          chunked["coordinates"] = coords
          r = RestClient.post "https://ossindex.sonatype.org/api/v3/component-report", chunked.to_json, 
          {content_type: :json, accept: :json, 'User-Agent': get_user_agent()}
        
          if r.code == 200
            @server_response = @server_response.concat(JSON.parse(r.body))
            save_values_to_db(JSON.parse(r.body))
            if !@options[:quiet] then spinner.success("...done.") end
            @server_response.count()
          else
            if !@options[:quiet] then spinner.stop("...request failed.") end
            print_err "Error getting data from OSS Index server. Server returned non-success code #{r.code}."
            0
          end
        end
      else
        if !@options[:quiet] then spinner.success("...done.") end
        @server_response.count()
      end
    rescue SocketError => e
      if !@options[:quiet] then spinner.stop("...request failed.") end
      print_err "Socket error getting data from OSS Index server."
      0      
    rescue RestClient::RequestFailed => e
      if !@options[:quiet] then spinner.stop("Request failed.") end
      print_err "Error getting data from OSS Index server:#{e.response}."
      0
    rescue RestClient::ResourceNotfound => e
      if !@options[:quiet] then spinner.stop("...request failed.") end
      print_err "Error getting data from OSS Index server. Resource not found."
      0
    rescue Errno::ECONNREFUSED => e
      if !@options[:quiet] then spinner.stop("...request failed.") end
      print_err "Error getting data from OSS Index server. Connection refused."
      0
    rescue StandardError => e
      if !@options[:quiet] then spinner.stop("...request failed.") end 
      print_err "UNKNOWN Error getting data from OSS Index server."
      0
    end

    def print_results
      response = String.new
      response += "\n"\
                  "Audit Results\n"\
                  "=============\n"
      i = 0
      count = server_response.count()

      server_response.each do |r|
        i += 1
        package = r["coordinates"]
        vulnerable = r["vulnerabilities"].length() > 0
        coord = r["coordinates"].sub("pkg:gem/", "")
        name = coord.split('@')[0]
        version = coord.split('@')[1]
        reverse_dep_coord = "#{name}-#{version}"
        if vulnerable
          response += @pastel.red("[#{i}/#{count}] - #{package} ") +  @pastel.red.bold("Vulnerable.\n")
          response += print_reverse_deps(@reverse_deps[reverse_dep_coord], name, version)
          r["vulnerabilities"].each do |k, v|
            response += @pastel.red.bold("    #{k}:#{v}")
          end
        else
          response += @pastel.white("[#{i}/#{count}] - #{package} ") + @pastel.green.bold("No vulnerabilities found!\n")
          response += print_reverse_deps(@reverse_deps[reverse_dep_coord], name, version)
        end
      end

      response
    end

    def spin(msg)
      spinner = TTY::Spinner.new(
        "[#{@pastel.green(':spinner')}] " + @pastel.white(msg.to_s),
        success_mark: @pastel.green('+'),
        hide_cursor: true
      )
      spinner.auto_spin()
    end

    def print_reverse_deps(reverse_deps, name, version)
      reverse_deps.each do |dep|
        dep.each do |gran|
          if gran.class == String && !gran.include?(name)
            # There is likely a fun and clever way to check @server-results, etc... and see if a dep is in there
            # Right now this looks at all Ruby deps, so it might find some in your Library, but that don't belong to your project
            puts "\tRequired by: " + gran
          else
          end
        end
      end
    end

    def print_err(s)
      puts @pastel.red.bold(s)
    end

    def print_success(s)
      puts @pastel.green.bold(s)
    end

    def _gemfile_lock_file_exists?
      if not ::File.file? @file
        return false
      else
        return true
      end
    end
  end
end
