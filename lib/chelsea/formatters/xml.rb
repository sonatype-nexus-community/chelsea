require 'ox'
require_relative 'formatter'
module Chelsea
  class XMLFormatter < Formatter
    def initialize(options)
      @options = options
    end

    def get_results(server_response, reverse_deps)
      doc = Ox::Document.new
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = '1.0'
      instruct[:encoding] = 'UTF-8'
      instruct[:standalone] = 'yes'
      doc << instruct

      testsuite = Ox::Element.new('testsuite')
      testsuite[:name] = "purl"
      testsuite[:tests] = server_response.count()
      doc << testsuite

      server_response.each do |coord|
        testcase = Ox::Element.new('testcase')
        testcase[:classname] = coord["coordinates"]
        testcase[:name] = coord["coordinates"]

        if coord["vulnerabilities"].length() > 0
          failure = Ox::Element.new('failure')
          failure[:type] = "Vulnerable Dependency"
          failure << get_vulnerability_block(coord["vulnerabilities"])
          testcase << failure
        end

        testsuite << testcase
      end

      doc
    end

    def do_print(results)
      puts Ox.dump(results)
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
