require 'ox'

module Chelsea
  class XMLFormatter
    def initialize(options)
      @options = options
    end

    def print_results(server_response, reverse_deps)
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
          failure << coord["vulnerabilities"]
          testcase << failure
        end
        
        testsuite << testcase
      end

      puts Ox.dump(doc)
    end

  end
end
