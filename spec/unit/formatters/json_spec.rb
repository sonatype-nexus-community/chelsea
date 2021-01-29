# frozen_string_literal: true

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

require 'chelsea/formatters/json'
require 'json'
require_relative '../test_helper'

RSpec.describe Chelsea::JsonFormatter do # rubocop:disable Metrics/BlockLength
  it 'print_results brings back a valid json object' do # rubocop:disable Metrics/BlockLength
    server_response = []
    server_response.push(populate_server_response('test', 'test', 'test'))
    server_response.push(populate_server_response('test2', 'test2', 'test2'))
    server_response.push(
      populate_server_response_vulnerability(
        populate_server_response('pkg:npm/js-yaml@1.0.0', 'YAML 1.2 parser and serializer',
                                 'https://ossindex.sonatype.org/component/pkg:npm/js-yaml@1.0.0')
      )
    )
    command = Chelsea::JsonFormatter.new({})

    json = command.fetch_results(server_response, {})

    expect(json.class).to eq(String)

    result = JSON.parse(json)

    expect(result.class).to eq(Array)
    expect(result.count).to eq(3)

    # First test object, not vulnerable
    expect(result[0]['coordinates']).to eq('test')
    expect(result[0]['description']).to eq('test')
    expect(result[0]['reference']).to eq('test')
    expect(result[0]['vulnerabilities'].class).to eq(Array)
    expect(result[0]['vulnerabilities'].count).to eq(0)

    # Second test object, not vulnerable
    expect(result[1]['coordinates']).to eq('test2')
    expect(result[1]['description']).to eq('test2')
    expect(result[1]['reference']).to eq('test2')
    expect(result[1]['vulnerabilities'].class).to eq(Array)
    expect(result[1]['vulnerabilities'].count).to eq(0)

    # Third test object, has vulnerability
    expect(result[2]['coordinates']).to eq('pkg:npm/js-yaml@1.0.0')
    expect(result[2]['description']).to eq('YAML 1.2 parser and serializer')
    expect(result[2]['reference']).to eq('https://ossindex.sonatype.org/component/pkg:npm/js-yaml@1.0.0')
    expect(result[2]['vulnerabilities'].class).to eq(Array)
    expect(result[2]['vulnerabilities'].count).to eq(1)
    expect(result[2]['vulnerabilities'][0]['id']).to eq('913ec790-8fc6-49fc-b424-170c1b60c97c')
    expect(result[2]['vulnerabilities'][0]['title']).to eq('[CVE-2013-4660]  Improper Input Validation')
    # Did a length comparison because string comparison is odd here
    expect(result[2]['vulnerabilities'][0]['description'].length).to eq(225)
    expect(result[2]['vulnerabilities'][0]['cvssScore']).to eq(6.8)
    expect(result[2]['vulnerabilities'][0]['cvssVector']).to eq('AV:N/AC:M/Au:N/C:P/I:P/A:P')
    expect(result[2]['vulnerabilities'][0]['cve']).to eq('CVE-2013-4660')
    expect(result[2]['vulnerabilities'][0]['reference']).to eq('https://ossindex.sonatype.org/vuln/913ec790-8fc6-49fc-b424-170c1b60c97c')
  end
end
