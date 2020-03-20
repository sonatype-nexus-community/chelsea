# frozen_string_literal: true

require 'pastel'
require 'semantic'
require 'tty-spinner'
require_relative '../command'

module Chelsea
  module Commands
    class Gems < Chelsea::Command
      def initialize(file, options)
        @file = file
        @options = options
        @pastel = Pastel.new
        @dependencies = Hash.new()
        @dependencies_versions = Hash.new()
        @coordinates = Hash.new()
        @coordinates["coordinates"] = Array.new()
        @server_response = Array.new()
      end

      def execute(input: $stdin, output: $stdout)
        if not gemspec_file_exists?
          return
        end
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

      def gemspec_file_exists?()
        if not ::File.file? @file
          print_err "Could not fifnd .gemspec file #{@file}."
          return false
        else
          require 'pathname'
          path = Pathname.new(@file)  
          print_success "Using .gemspec file #{path.realpath}."
          return true
        end
      end

      def get_dependencies()
        format = "[#{@pastel.green(':spinner')}] " + @pastel.white("Parsing dependencies")
        spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
        spinner.auto_spin()
        IO.foreach(@file) do |x|
          case x
          when /^\s*spec\.add_dependency\s+"?([^"]+)"?,\s*(.+)$/
            p = $1
            v = $2.to_s
            r = 
              if v.start_with?('"') then 
                v.gsub!(/\A"|"\Z/, '') 
              else 
                v 
              end 
            @dependencies[p] = Gem::Requirement.parse(r)
          end
          rescue StandardError => e
            spinner.stop("...failed.")
            print_err "Parsing dependency line #{x} failed."
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
          version = Semantic::Version.new(v)
          case o
          when '>'
            version = version.increment!(:minor)
          when '<'
            version = decrement(version)
          end
          #puts "p:#{p} o:#{o} v:#{v} version:#{version}."
          @dependencies_versions[p] = version
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

      def get_vulns()
        require 'json'
        require 'rest-client'
        format = "[#{@pastel.green(':spinner')}] " + @pastel.white("Making request to OSS Index server")
        spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), hide_cursor: true)
        spinner.auto_spin()
        r = RestClient.post "https://ossindex.sonatype.org/api/v3/component-report", @coordinates.to_json, 
          {content_type: :json, accept: :json}
        if r.code == 200
          @server_response = JSON.parse(r.body)
          spinner.success("...done.")
          @server_response.count()
        else
          spinner.stop("...request failed.")
          print_err "Error getting data from OSS Index server. Server returned non-success code #{r.code}."
          0
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
        @server_response.each do |r|
          package = r["coordinates"].split('/')[1].split('@')
          vulnerable = r["vulnerabilities"].length() > 0
          desc = r["description"] != "" ? "#{r['description']}" : ""
          if vulnerable
            puts(@pastel.white("Package: #{package[0]} #{package[1]}. #{desc} ") +  @pastel.red.bold("Vulnerable."))
            r["vulnerabilities"].each do |k, v|
              puts @pastel.red.bold("    #{k}:#{v}")
              #@pastel.red.white.
            end
          else
            puts(@pastel.white("Package: #{package[0]} #{package[1]}. #{desc} ") + @pastel.green.bold("Not vulnerable."))
          end
          #puts r 
        end
      end

      def decrement(version)
        major = version.major
        minor = version.minor
        patch = version.patch
        if patch > 0 then
          patch = patch - 1
        elsif minor > 0 then
          minor = minor - 1
        elsif major > 0 then
          major = major - 1
        else raise 'Version is 0.0.0'
        end
        Semantic::Version.new("#{major}.#{minor}.#{patch}")
      end

      def print_err(s)
        puts @pastel.red.bold(s)
      end

      def print_success(s)
        puts @pastel.green.bold(s)
      end

    end
  end
end
