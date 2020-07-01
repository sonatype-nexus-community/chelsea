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

require 'ox'
require_relative 'formatter'
module Chelsea
  # class to format OIResponse and Reverse Deps as an XML Document
  # where are we sourcing XML spec?
  class XMLFormatter < Formatter
    attr_accessor :oi_response, :reverse_dependencies
    attr_reader :output
    def initialize(**options)
      @options = options
      @output = Ox::Document.new
    end

    def format_response
      doc = Ox::Document.new
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = '1.0'
      instruct[:encoding] = 'UTF-8'
      instruct[:standalone] = 'yes'
      doc << instruct

      testsuite = Ox::Element.new('testsuite')
      testsuite[:name] = 'purl'
      testsuite[:tests] = @oi_response.dep_count

      @oi_response.coords.map(&:to_h).each do |coord|
        testcase = Ox::Element.new('testcase')
        testcase[:classname] = coord[:coordinates]
        testcase[:name] = coord[:coordinates]
        if coord[:vulnerabilities].length.positive?
          failure = Ox::Element.new('failure')
          failure[:type] = 'Vulnerable Dependency'
          failure << get_vulnerability_block(coord[:vulnerabilities])
          testcase << failure
          testsuite << testcase
        elsif @options[:verbose]
          testsuite << testcase
        end
      end
      doc << testsuite
      @output = doc
    end

    def do_print
      Ox.dump(@output)
    end

    def get_vulnerability_block(vulnerabilities)
      vuln_block = ''
      vulnerabilities.each do |vuln|
        vuln_block += \
          "Vulnerability Title: #{vuln['title']}\n"\
          "ID: #{vuln['id']}\n"\
          "Description: #{vuln['description']}\n"\
          "CVSS Score: #{vuln['cvssScore']}\n"\
          "CVSS Vector: #{vuln['cvssVector']}\n"\
          "CVE: #{vuln['cve']}\n"\
          "Reference: #{vuln['reference']}"\
          "\n"
      end
      vuln_block
    end
  end
end
