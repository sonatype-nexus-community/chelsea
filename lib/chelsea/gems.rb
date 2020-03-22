# frozen_string_literal: true

require 'pastel'
require 'tty-spinner'
require 'bundler'
require 'bundler/lockfile_parser'
require_relative 'version'
require 'rubygems'
require 'rubygems/commands/dependency_command'

module Chelsea
  class Gems
    def initialize(file, options)
      @file = file
      @options = options
      @pastel = Pastel.new
      @dependencies = Hash.new()
      @dependencies_versions = Hash.new()
      @coordinates = Hash.new()
      @coordinates["coordinates"] = Array.new()
      @server_response = Array.new()
      @reverse_deps = Hash.new()

      if not gemfile_lock_file_exists()
        return
      end

      path = Pathname.new(@file)
      @lockfile = Bundler::LockfileParser.new(
        File.read(path)
      )
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
      print_results()
    end

    def gemfile_lock_file_exists()
      if not ::File.file? @file
        return false
      else
        path = Pathname.new(@file)
        return true
      end
    end

    def get_dependencies()
      format = "[#{@pastel.green(':spinner')}] " + @pastel.white("Parsing dependencies")
      spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
      spinner.auto_spin()

      reverse = Gem::Commands::DependencyCommand.new
      reverse.options[:reverse_dependencies] = true
      @reverse_deps = reverse.reverse_dependencies(@lockfile.specs)

      @lockfile.specs.each do |gem|
        @dependencies[gem.name] = [gem.name, gem.version]
        rescue StandardError => e
          spinner.stop("...failed.")
          print_err "Parsing dependency line #{gem} failed."
      end

      c = @dependencies.count()
      spinner.success("...done. Parsed #{c} dependencies.")
      c
    end

    def get_dependencies_versions()
      format = "[#{@pastel.green(':spinner')}] " + @pastel.white("Parsing versions")
      spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
      spinner.auto_spin()
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
      spinner.success("...done.")
      c
    end

    def get_coordinates()
      @dependencies_versions.each do |p, v|
        @coordinates["coordinates"] <<  "pkg:gem/#{p}@#{v}";
      end
    end

    def get_user_agent()
      user_agent = "chelsea/#{Chelsea::VERSION}"

      user_agent
    end

    def get_vulns()
      require 'json'
      require 'rest-client'
      format = "[#{@pastel.green(':spinner')}] " + @pastel.white("Making request to OSS Index server")
      spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
      spinner.auto_spin()

      chunked = Hash.new()
      chunks = @coordinates["coordinates"].each_slice(128).to_a
      chunks.each do |coords|
        chunked["coordinates"] = coords
        r = RestClient.post "https://ossindex.sonatype.org/api/v3/component-report", chunked.to_json, 
        {content_type: :json, accept: :json, 'User-Agent': get_user_agent()}
      
        if r.code == 200
          @server_response = @server_response.concat(JSON.parse(r.body))
          spinner.success("...done.")
          @server_response.count()
        else
          spinner.stop("...request failed.")
          print_err "Error getting data from OSS Index server. Server returned non-success code #{r.code}."
          0
        end
      end
    rescue SocketError => e
      spinner.stop("...request failed.")
      print_err "Socket error getting data from OSS Index server."
      0      
    rescue RestClient::RequestFailed => e
      spinner.stop("Request failed.")
      print_err "Error getting data from OSS Index server:#{e.response}."
      0
    rescue RestClient::ResourceNotfound => e
      spinner.stop("...request failed.")
      print_err "Error getting data from OSS Index server. Resource not found."
      0
    rescue Errno::ECONNREFUSED => e
      spinner.stop("...request failed.")
      print_err "Error getting data from OSS Index server. Connection refused."
      0
    rescue StandardError => e
      spinner.stop("...request failed.")
      print_err "UNKNOWN Error getting data from OSS Index server."
      0
    end

    def print_results()
      puts ""
      puts "Audit Results"
      puts "============="
      i = 0
      count = @server_response.count()
      @server_response.each do |r|
        i += 1
        package = r["coordinates"]
        vulnerable = r["vulnerabilities"].length() > 0
        coord = r["coordinates"].sub("pkg:gem/", "")
        name = coord.split('@')[0]
        version = coord.split('@')[1]
        reverse_dep_coord = "#{name}-#{version}"
        if vulnerable
          puts @pastel.red("[#{i}/#{count}] - #{package} ") +  @pastel.red.bold("Vulnerable.")
          print_reverse_deps(@reverse_deps[reverse_dep_coord], name, version)
          r["vulnerabilities"].each do |k, v|
            puts @pastel.red.bold("    #{k}:#{v}")
          end
        else
          puts(@pastel.white("[#{i}/#{count}] - #{package} ") + @pastel.green.bold("No vulnerabilities found!"))
          print_reverse_deps(@reverse_deps[reverse_dep_coord], name, version)
        end
      end
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

    def to_purl(name, version)
      purl = "pkg:gem/#{name}@#{version}"

      purl
    end

    def print_err(s)
      puts @pastel.red.bold(s)
    end

    def print_success(s)
      puts @pastel.green.bold(s)
    end
  end
end
