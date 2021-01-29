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

require 'chelsea/formatters/xml'

RSpec.describe Chelsea::XMLFormatter do
  it 'print_results brings back a Ox xml style object' do
    expected_vuln_block = "Vulnerability Title: [CVE-2013-4660]  Improper Input Validation\n"\
    "ID: 913ec790-8fc6-49fc-b424-170c1b60c97c\n"\
    "Description: The JS-YAML module before 2.0.5 for Node.js parses input without properly considering the unsafe !!js/function tag, which allows remote attackers to execute arbitrary code via a crafted string that triggers an eval operation.\n"\
    "CVSS Score: 6.8\n"\
    "CVSS Vector: AV:N/AC:M/Au:N/C:P/I:P/A:P\n"\
    "CVE: CVE-2013-4660\n"\
    "Reference: https://ossindex.sonatype.org/vuln/913ec790-8fc6-49fc-b424-170c1b60c97c\n"

    server_response = []
    server_response.push(populate_server_response('test', 'test', 'test'))
    server_response.push(populate_server_response('test2', 'test2', 'test2'))
    server_response.push(populate_server_response_vulnerability(populate_server_response('pkg:npm/js-yaml@1.0.0',
                                                                                         'YAML 1.2 parser and serializer', 'https://ossindex.sonatype.org/component/pkg:npm/js-yaml@1.0.0')))
    command = Chelsea::XMLFormatter.new({ verbose: true })

    xml = command.get_results(server_response, {})

    expect(xml.class).to eq(Ox::Document)

    expect(xml.xml.attributes[:version]).to eq('1.0')
    expect(xml.xml.attributes[:encoding]).to eq('UTF-8')
    expect(xml.xml.attributes[:standalone]).to eq('yes')

    expect(xml.testsuite.nodes.length).to eq(3)
    expect(xml.testsuite.nodes[0].attributes[:classname]).to eq('test')
    expect(xml.testsuite.nodes[0].attributes[:name]).to eq('test')
    expect(xml.testsuite.nodes[1].attributes[:classname]).to eq('test2')
    expect(xml.testsuite.nodes[1].attributes[:name]).to eq('test2')
    expect(xml.testsuite.nodes[2].attributes[:classname]).to eq('pkg:npm/js-yaml@1.0.0')
    expect(xml.testsuite.nodes[2].attributes[:name]).to eq('pkg:npm/js-yaml@1.0.0')
    expect(xml.testsuite.nodes[2].nodes[0].text).to eq(expected_vuln_block)
  end
end
