require 'pastel'

module Chelsea
  class TextFormatter
    def initialize(options)
      @options = options
      @pastel = Pastel.new
    end

    def print_results(server_response, reverse_deps)
      if @options['quiet']
        puts ""
        puts "Audit Results"
        puts "============="
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
          puts @pastel.red("[#{i}/#{count}] - #{package} ") +  @pastel.red.bold("Vulnerable.")
          print_reverse_deps(reverse_deps[reverse_dep_coord], name, version)
          r["vulnerabilities"].each do |k, v|
            puts @pastel.red.bold("    #{k}:#{v}")
          end
        else
          if @options['quiet']
            puts(@pastel.white("[#{i}/#{count}] - #{package} ") + @pastel.green.bold("No vulnerabilities found!"))
            print_reverse_deps(reverse_deps[reverse_dep_coord], name, version)
          end
        end
      end
    end

    private 

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

  end
end
