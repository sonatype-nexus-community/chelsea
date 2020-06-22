#
# Copyright 2019-Present Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'pastel'
require 'tty-table'
require_relative 'formatter'

module Chelsea
  class TextFormatter < Formatter
    def initialize(verbose: false)
      @verbose = verbose
      @pastel = Pastel.new
    end

    def get_results(server_response, reverse_dependencies)
      response = ''
      if @verbose
        response += "\n"\
        "Audit Results\n"\
        "=============\n"
      end

      vuln_count = server_response.count do |vuln|
        vuln['vulnerabilities'].length.positive?
      end
      server_response.sort! { |x| x['vulnerabilities'].count }
      server_response.each.with_index do |r, idx|
        name, version = r['coordinates'].sub('pkg:gem/', '').split('@')
        reverse_deps = reverse_dependencies["#{name}-#{version}"]
        if r['vulnerabilities'].length.positive?
          response += @pastel.red(
            "[#{idx}/#{server_response.count}] - #{r['coordinates']} "
          )
          response += @pastel.red.bold("Vulnerable.\n")
          response += _get_reverse_deps(reverse_deps, name) if reverse_deps
          r['vulnerabilities'].each do |k, _|
            response += _format_vuln(k)
          end
        elsif @verbose
          response += @pastel.white(
            "[#{idx}/#{server_response.count}] - #{r['coordinates']} "
          )
          response += @pastel.green.bold("No vulnerabilities found!\n")
          response += _get_reverse_deps(reverse_deps, name) if reverse_deps
        end
      end

      table = TTY::Table.new(
        ['Dependencies Audited', 'Vulnerable Dependencies'],
        [[server_response.count, vuln_count]]
      )
      response += table.render(:unicode)
      response
    end

    def do_print(results)
      puts results
    end

    private

    def _format_vuln(vuln)
      vuln_response = "\n\tVulnerability Details:\n"
      _color_method = _color_based_on_cvss_score(vuln['cvssScore'])
      _report_lines(vuln).each do |line|
        vuln_response += _color_method(line)
      end
      vuln_response
    end

    def _report_lines(vuln)
      [
        "\n\tID: #{vuln['id']}\n",
        "\n\tTitle: #{vuln['title']}\n",
        "\n\tDescription: #{vuln['description']}\n",
        "\n\tCVSS Score: #{vuln['cvssScore']}\n",
        "\n\tCVSS Vector: #{vuln['cvssVector']}\n",
        "\n\tCVE: #{vuln['cve']}\n",
        "\n\tReference: #{vuln['reference']}\n\n"
      ]
    end

    def _color_based_on_cvss_score(cvss_score)
      case cvss_score
      when 0..3
        @pastel.cyan.bold
      when 4..5
        @pastel.yellow.bold
      when 6..7
        @pastel.orange.bold
      else
        @pastel.red.bold
      end
    end

    def _get_reverse_deps(coords, name)
      coords.each_with_object('') do |dep, s|
        dep.each do |gran|
          if gran.class == String && !gran.include?(name)
            s << "\tRequired by: #{gran}\n"
          end
        end
      end
    end
  end
end
