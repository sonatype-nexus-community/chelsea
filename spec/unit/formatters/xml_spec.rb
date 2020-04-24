require 'chelsea/formatters/xml'

RSpec.describe Chelsea::XMLFormatter do
  it "print_results brings back a Ox xml style object" do
    expected_vuln_block = "Vulnerability Title: [CVE-2013-4660]  Improper Input Validation\n"\
    "ID: 913ec790-8fc6-49fc-b424-170c1b60c97c\n"\
    "Description: The JS-YAML module before 2.0.5 for Node.js parses input without properly considering the unsafe !!js/function tag, which allows remote attackers to execute arbitrary code via a crafted string that triggers an eval operation.\n"\
    "CVSS Score: 6.8\n"\
    "CVSS Vector: AV:N/AC:M/Au:N/C:P/I:P/A:P\n"\
    "CVE: CVE-2013-4660\n"\
    "Reference: https://ossindex.sonatype.org/vuln/913ec790-8fc6-49fc-b424-170c1b60c97c\n"

    server_response = Array.new
    server_response.push(populate_server_response("test", "test", "test")) 
    server_response.push(populate_server_response("test2", "test2", "test2"))
    server_response.push(populate_server_response_vulnerability(populate_server_response("pkg:npm/js-yaml@1.0.0", "YAML 1.2 parser and serializer", "https://ossindex.sonatype.org/component/pkg:npm/js-yaml@1.0.0")))
    command = Chelsea::XMLFormatter.new(server_response: server_response, reverse_dependencies: {})

    xml = command.results

    expect(xml.class).to eq(Ox::Document)

    expect(xml.xml.attributes[:version]).to eq("1.0")
    expect(xml.xml.attributes[:encoding]).to eq("UTF-8")
    expect(xml.xml.attributes[:standalone]).to eq("yes")

    expect(xml.testsuite.nodes.length).to eq(3)
    expect(xml.testsuite.nodes[0].attributes[:classname]).to eq("test")
    expect(xml.testsuite.nodes[0].attributes[:name]).to eq("test")
    expect(xml.testsuite.nodes[1].attributes[:classname]).to eq("test2")
    expect(xml.testsuite.nodes[1].attributes[:name]).to eq("test2")
    expect(xml.testsuite.nodes[2].attributes[:classname]).to eq("pkg:npm/js-yaml@1.0.0")
    expect(xml.testsuite.nodes[2].attributes[:name]).to eq("pkg:npm/js-yaml@1.0.0")
    expect(xml.testsuite.nodes[2].nodes[0].text).to eq(expected_vuln_block)
  end
end
