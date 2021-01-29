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

def populate_server_response(coordinate, desc, reference)
  response = {}
  response['coordinates'] = coordinate
  response['description'] = desc
  response['reference'] = reference
  response['vulnerabilities'] = []

  response
end

def populate_server_response_vulnerability(server_response) # rubocop:disable Metrics/MethodLength
  vulnerability = {}
  vulnerability['id'] = '913ec790-8fc6-49fc-b424-170c1b60c97c'
  vulnerability['title'] = '[CVE-2013-4660]  Improper Input Validation'
  # rubocop:disable Layout/LineLength
  vulnerability['description'] =
    'The JS-YAML module before 2.0.5 for Node.js parses input without properly considering the unsafe !!js/function tag, which allows remote attackers to execute arbitrary code via a crafted string that triggers an eval operation.'
  # rubocop:enable Layout/LineLength
  vulnerability['cvssScore'] = 6.8
  vulnerability['cvssVector'] = 'AV:N/AC:M/Au:N/C:P/I:P/A:P'
  vulnerability['cve'] = 'CVE-2013-4660'
  vulnerability['reference'] = 'https://ossindex.sonatype.org/vuln/913ec790-8fc6-49fc-b424-170c1b60c97c'
  server_response['vulnerabilities'].push(vulnerability)

  server_response
end
