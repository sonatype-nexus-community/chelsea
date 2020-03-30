# frozen_string_literal: true

require 'pastel'
require 'tty-spinner'
require_relative 'oss_index'
require_relative 'deps'

module Chelsea
  class Gems
    def initialize(file)
      @file = file
      @pastel = Pastel.new
    end

    def execute(input: $stdin, output: $stdout)
      if not gemfile_lock_file_exists()
        raise "Gemfile.lock not found, check --file path"
      end

      deps = Chelsea::Deps.new({path: Pathname.new(@file)})
      ossindex = Chelsea::OssIndex.new({})

      begin
        spinner = TTY::Spinner.new(
          "[#{@pastel.green(':spinner')}] " + @pastel.white("Parsing dependencies"), 
          success_mark: @pastel.green('+'), 
          hide_cursor: true
        )
        spinner.auto_spin()

        dependencies = Hash.new()   
        dependencies = deps.get_dependencies()

        spinner.success("...done. Parsed #{dependencies.count()} dependencies.")

        reverse_deps = deps.get_reverse_dependencies()

        spinner = TTY::Spinner.new(
          "[#{@pastel.green(':spinner')}] " + @pastel.white("Parsing versions"), 
          success_mark: @pastel.green('+'), 
          hide_cursor: true
        )
        spinner.auto_spin()

        coordinates = Hash.new()
        coordinates = deps.get_dependencies_versions_as_coordinates(dependencies)

        spinner.success("...done.")

        spinner = TTY::Spinner.new(
          "[#{@pastel.green(':spinner')}] " + @pastel.white("Making request to OSS Index server"), 
          success_mark: @pastel.green('+'), 
          hide_cursor: true
        )
        spinner.auto_spin()

        server_response = Array.new
        server_response = ossindex.query_ossindex_for_vulns(coordinates)
        if server_response.count() == 0
          spinner.stop("...failed.")
          print_err "No vulnerability data retrieved from server. Exiting."
          return
        end

        spinner.success("...done.")

        print_results(server_response, reverse_deps)
      rescue Chelsea::OssIndexException => e
        spinner.stop("...failed.")
        print_err e
      end
    end

    private

    def print_results(server_response, reverse_deps)
      puts ""
      puts "Audit Results"
      puts "============="

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
          puts @pastel.red("[#{i}/#{count}] - #{package} ") +  @pastel.red.bold("Vulnerable.")
          print_reverse_deps(reverse_deps[reverse_dep_coord], name, version)
          r["vulnerabilities"].each do |k, v|
            puts @pastel.red.bold("    #{k}:#{v}")
          end
        else
          puts(@pastel.white("[#{i}/#{count}] - #{package} ") + @pastel.green.bold("No vulnerabilities found!"))
          print_reverse_deps(reverse_deps[reverse_dep_coord], name, version)
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

    def print_err(s)
      puts @pastel.red.bold(s)
    end

    def print_success(s)
      puts @pastel.green.bold(s)
    end

    def gemfile_lock_file_exists()
      if not ::File.file? @file
        return false
      else
        path = Pathname.new(@file)
        return true
      end
    end
  end
end
