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
  # Formats Server response and reverse dependencies to JSON
  class TextFormatter < Formatter
    attr_accessor :oi_response, :reverse_dependencies
    def initialize(options)
      @options = options
      @pastel = Pastel.new
      @output = ''
    end

    def format_response
      @oi_response.json.map.with_index do |dep, idx|
        reverse_deps = @reverse_dependencies["#{dep[:name]}-#{dep[:version]}"]
        header = "[#{idx}/#{oi_response.dep_count}] - #{dep[:coordinates]} "
        if dep[:vulnerable]
          @output += @pastel.red(header)
          @output += @pastel.red.bold("Vulnerable.\n")
          @output += _parse_reverse_deps(reverse_deps, dep[:name]) if reverse_deps
          _write_vulnerable_coordinates
        elsif @options[:verbose]
          @output += @pastel.red(header)
          @output += @pastel.green.bold("No vulnerabilities found!\n")
          @output += _parse_reverse_deps(reverse_deps, dep[:name]) if reverse_deps
        end
      end

      table = TTY::Table.new(
        ['Dependencies Audited', 'Vulnerable Dependencies'],
        [[oi_response.dep_count, oi_response.vuln_count]]
      )
      @output += table.render(:unicode)
    end

    def do_print
      _write_header if @options[:verbose]
      format_response
      puts @output
    end

    private

    def _write_header
      @output += "\n"\
        "Audit Results\n"\
        "=============\n"
    end

    def _write_vulnerable_coordinates(res)
      res['vulnerabilities'].each do |k, _|
        @output += _format_vuln(k)
      end
    end

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

    def _parse_reverse_deps(coords, name)
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
