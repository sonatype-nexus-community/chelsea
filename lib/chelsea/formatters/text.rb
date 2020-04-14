require 'pastel'
require_relative 'formatter'

module Chelsea
  class TextFormatter < Formatter
    def initialize(quiet: false)
      @quiet = quiet
      @pastel = Pastel.new
    end

    def get_results(server_response, reverse_dependencies)
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
        package = r['coordinates']
        vulnerable = r['vulnerabilities'].length.positive?
        coord = r['coordinates'].sub('pkg:gem/', '')
        name = coord.split('@')[0]
        version = coord.split('@')[1]
        reverse_deps = reverse_dependencies["#{name}-#{version}"]
        if vulnerable
          response += @pastel.red("[#{i}/#{count}] - #{package} ") + @pastel.red.bold('Vulnerable.\n')
          response += _get_reverse_deps(reverse_deps, name)
          r['vulnerabilities'].each do |k, v|
            response += @pastel.red.bold("    #{k}:#{v}\n")
          end
        else
          if !@quiet
            response += @pastel.white("[#{i}/#{count}] - #{package} ") + @pastel.green.bold('No vulnerabilities found!\n')
            response += _get_reverse_deps(reverse_deps, name)
          end
        end
      end

      response
    end

    def do_print(results)
      puts results
    end

    # Right now this looks at all Ruby deps, so it might find some in your Library, but that don't belong to your project
    def _get_reverse_deps(coord, name)
      response = String.new
      coord.each do |dep|
        dep.each do |gran|
          if gran.class == String && !gran.include?(name)
            response += "\tRequired by: #{gran}\n"
          end
        end
      end
      response
    end
  end
end
