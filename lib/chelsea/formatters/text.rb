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
          response += @pastel.red("[#{i}/#{count}] - #{package} ") + @pastel.red.bold("Vulnerable.\n")
          response += _get_reverse_deps(reverse_deps, name) if reverse_deps
          r['vulnerabilities'].each do |v|
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
      cvssScore = vuln['cvssScore']
      vuln_response = "\n\tVulnerability Details:\n"
      vuln_response += _color_based_on_cvss_score(cvssScore, "\n\tID: #{vuln['id']}\n")
      vuln_response += _color_based_on_cvss_score(cvssScore, "\n\tTitle: #{vuln['title']}\n")
      vuln_response += _color_based_on_cvss_score(cvssScore, "\n\tDescription: #{vuln['description']}\n")
      vuln_response += _color_based_on_cvss_score(cvssScore, "\n\tCVSS Score: #{vuln['cvssScore']}\n")
      vuln_response += _color_based_on_cvss_score(cvssScore, "\n\tCVSS Vector: #{vuln['cvssVector']}\n")
      vuln_response += _color_based_on_cvss_score(cvssScore, "\n\tCVE: #{vuln['cve']}\n")
      vuln_response += _color_based_on_cvss_score(cvssScore, "\n\tReference: #{vuln['reference']}\n\n")
      vuln_response
    end

    def _color_based_on_cvss_score(cvssScore, text)
      if cvssScore > 0 && cvssScore < 4
        @pastel.cyan.bold(text)
      elsif cvssScore > 4 && cvssScore < 6
        @pastel.yellow.bold(text)
      elsif cvssScore > 6 && cvssScore < 8
        @pastel.orange.bold(text)
      elsif cvssScore > 8
        @pastel.red.bold(text)
      end
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
