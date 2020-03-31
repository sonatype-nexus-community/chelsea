# frozen_string_literal: true

require 'pastel'
require 'tty-spinner'
require_relative 'oss_index'
require_relative 'deps'

module Chelsea
  class Gems
    def initialize(file)
      @file = file
      if not _gemfile_lock_file_exists?
        raise "Gemfile.lock not found, check --file path"
      end
      @pastel = Pastel.new
      @deps = Chelsea::Deps.new({path: Pathname.new(@file)})
      @ossindex = Chelsea::OssIndex.new({})

    end

    def execute(input: $stdin, output: $stdout)
      begin
        deps_hash = _parse_deps
        reverse_deps_hash = _parse_reverse_deps
        spin("Parsing versions")

        # spinner.success("...done.")

        spin("Making request to OSS Index server")
        coordinates = _parse_versions(deps_hash)
        server_response = @ossindex.query_ossindex_for_vulns(coordinates).to_a

        if server_response.count() == 0
          spinner.stop("...failed.")
          print_err "No vulnerability data retrieved from server. Exiting."
          return
        end

        # spinner.success("...done.")

        print_results(server_response, reverse_deps_hash)
      rescue Chelsea::OssIndexException => e
        spinner.stop("...failed.")
        print_err e
      end
    end

    private

    def _parse_deps
      spin("Parsing dependencies")
      @deps.to_h
      # spin.success("...done. Parsed #{dependencies.count()} dependencies.")
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
