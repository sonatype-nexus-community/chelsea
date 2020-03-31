require 'pastel'

module Chelsea
  class TextFormatter
    def initialize(quiet: false)
      @quiet = quiet
      @pastel = Pastel.new
    end

    def get_results(server_response, reverse_deps)
      response = String.new
      if !@quiet
        response += "\n"\
        "Audit Results\n"\
        "=============\n"
      end

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
          response += print_reverse_deps(reverse_deps[reverse_dep_coord], name, version)
          r["vulnerabilities"].each do |k, v|
            response += @pastel.red.bold("    #{k}:#{v}\n")
          end
        else
          if !@quiet
            response += @pastel.white("[#{i}/#{count}] - #{package} ") + @pastel.green.bold("No vulnerabilities found!\n")
            response += print_reverse_deps(reverse_deps[reverse_dep_coord], name, version)
          end
        end
      end

      response
    end

    def do_print(results)
      puts results
    end

    private 

    def print_reverse_deps(reverse_deps, name, version)
      response = String.new
      reverse_deps.each do |dep|
        dep.each do |gran|
          if gran.class == String && !gran.include?(name)
            # There is likely a fun and clever way to check @server-results, etc... and see if a dep is in there
            # Right now this looks at all Ruby deps, so it might find some in your Library, but that don't belong to your project
            response += "\tRequired by: #{gran}\n"
          else
          end
        end
      end

      response
    end

  end
end
