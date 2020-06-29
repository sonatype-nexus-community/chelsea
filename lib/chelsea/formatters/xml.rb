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
  class XMLFormatter < Formatter
    def initialize(options)
      @options = options
    end

    def get_results(server_response:, reverse_dependencies:)
      doc = Ox::Document.new
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = '1.0'
      instruct[:encoding] = 'UTF-8'
      instruct[:standalone] = 'yes'
      doc << instruct

      testsuite = Ox::Element.new('testsuite')
      testsuite[:name] = 'purl'
      testsuite[:tests] = server_response.count
      doc << testsuite

      server_response.each do |coord|
        testcase = Ox::Element.new('testcase')
        testcase[:classname] = coord["coordinates"]
        testcase[:name] = coord["coordinates"]

        if coord['vulnerabilities'].length.positive?
          failure = Ox::Element.new('failure')
          failure[:type] = "Vulnerable Dependency"
          failure << get_vulnerability_block(coord["vulnerabilities"])
          testcase << failure
          testsuite << testcase
        elsif @options[:verbose]
          testsuite << testcase
        end
      end

      @output = doc
    end

    def do_print
      Ox.dump(@output)
    end

    def get_vulnerability_block(vulnerabilities)
      vulnBlock = String.new
      vulnerabilities.each do |vuln|
        vulnBlock += "Vulnerability Title: #{vuln["title"]}\n"\
                    "ID: #{vuln["id"]}\n"\
                    "Description: #{vuln["description"]}\n"\
                    "CVSS Score: #{vuln["cvssScore"]}\n"\
                    "CVSS Vector: #{vuln["cvssVector"]}\n"\
                    "CVE: #{vuln["cve"]}\n"\
                    "Reference: #{vuln["reference"]}"\
                    "\n"
      end
      
      vulnBlock
    end
  end
end
