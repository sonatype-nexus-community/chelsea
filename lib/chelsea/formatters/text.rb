require 'pastel'
require 'pry'
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
          response += @pastel.red("[#{i}/#{count}] - #{package} ") + @pastel.red.bold("Vulnerable.\n")
          response += _get_reverse_deps(reverse_deps, name) if reverse_deps
          r['vulnerabilities'].each do |k, v|
            response += _format_vuln(v)
          end
        else
          if !@quiet
            response += @pastel.white("[#{i}/#{count}] - #{package} ") + @pastel.green.bold("No vulnerabilities found!\n")
            response += _get_reverse_deps(reverse_deps, name) if reverse_deps
          end
        end
      end

      response
    end

    def do_print(results)
      puts results
    end

    def _format_vuln(vuln)
      @pastel.red.bold("\n#{vuln}\n")
    end

    def _get_reverse_deps(coords, name)
      coords.each_with_object(String.new) do |dep, s|
        dep.each do |gran|
          if gran.class == String && !gran.include?(name)
            s << "\tRequired by: #{gran}\n"
          end
        end
      end
    end
  end
end
