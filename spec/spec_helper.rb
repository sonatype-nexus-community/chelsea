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

require 'json'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

def process_deps_from_gemfile(file)
  deps = Chelsea::Deps.new({ path: Pathname.new(file) })
  dependencies = deps.dependencies
  reverse_dependencies = deps.reverse_dependencies
  coordinates = deps.coordinates
  [dependencies, reverse_dependencies, coordinates]
end

def _json_headers
  {
    'Accept' => 'application/json',
    'Accept-Encoding' => 'gzip, deflate',
    'Content-Length' => '172',
    'Content-Type' => 'application/json',
    'Host' => 'ossindex.sonatype.org',
    'User-Agent' => 'chelsea/0.0.8'
  }
end

def stub_sbom(server_url: 'localhost:8070', stage: 'build', **_opts)
  stub_request(
    :post,
    "http://#{server_url}/api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/sources/chelsea?stageId=#{stage}"
  )
    .to_return(
      # rubocop:disable Layout/LineLength
      body: JSON.unparse({ statusUrl: 'api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/status/9cee2b6366fc4d328edc318eae46b2cb' }),
      # rubocop:enable Layout/LineLength
      status: 202,
      headers: _json_headers
    )
end

# rubocop:disable Metrics/MethodLength
def stub_iq_response(server_url: 'localhost:8070', public_application_id: 'testapp', **_opts)
  stub_request(
    :get,
    "http://#{server_url}/api/v2/applications?publicId=#{public_application_id}"
  )
    .to_return(
      body:
        JSON.unparse(
          {
            applications:
            [
              {
                id: '4537e6fe68c24dd5ac83efd97d4fc2f4',
                publicId: 'MyApplicationID',
                name: 'MyApplication',
                organizationId: 'bb41817bd3e2403a8a52fe8bcd8fe25a',
                contactUserName: 'NewAppContact',
                applicationTags: [
                  {
                    id: '9beee80c6fc148dfa51e8b0359ee4d4e',
                    tagId: 'cfea8fa79df64283bd64e5b6b624ba48',
                    applicationId: '4bb67dcfc86344e3a483832f8c496419'
                  }
                ]
              }
            ]
          }
        ),
      status: 200,
      headers: _json_headers
    )
end
# rubocop:enable Metrics/MethodLength

# rubocop:disable Metrics/MethodLength
def stub_iq_poll_response(server_url: 'localhost:8070', policy_action: 'None',
                          report_html_url: 'ui/links/application/test-app/report/95c4c14e', **_opts)
  stub_request(
    :get,
    # rubocop:disable Layout/LineLength
    "http://#{server_url}/api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/status/9cee2b6366fc4d328edc318eae46b2cb"
    # rubocop:enable Layout/LineLength
  )
    .to_return(
      body:
        JSON.unparse({
                       policyAction: policy_action.to_s,
                       reportHtmlUrl: report_html_url.to_s,
                       reportPdfUrl: 'ui/links/application/test-app/report/95c4c14e/pdf',
                       reportDataUrl: 'api/v2/applications/test-app/reports/95c4c14e/raw',
                       embeddableReportHtmlUrl: 'ui/links/application/test-app/report/95c4c14e/embeddable',
                       isError: false
                     }),
      status: 200,
      headers: _json_headers
    )
end
# rubocop:enable Metrics/MethodLength

def oss_index_response
  File.open("#{File.dirname(__FILE__)}/testdata/oss_response.json", 'rb').read
end

def stub_oss_response
  stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report')
    .to_return(status: 200, body: OSS_INDEX_RESPONSE, headers: { 'Content-Type' => 'application/json' })
end

def test_dependencies # rubocop:disable Metrics/MethodLength
  stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report')
    .with(
      body: '{"coordinates":["pkg:gem/addressable@2.7.0","pkg:gem/crack@0.4.3","pkg:gem/hashdiff@1.0.1","pkg:gem/public_suffix@4.0.3","pkg:gem/safe_yaml@1.0.5","pkg:gem/webmock@3.8.3"]}',
      headers: {
        'Accept' => 'application/json',
        'Accept-Encoding' => 'gzip, deflate',
        'Content-Length' => '172',
        'Content-Type' => 'application/json',
        'Host' => 'ossindex.sonatype.org',
        'User-Agent' => 'chelsea/0.0.3'
      }
    ).to_return(status: 200, body: OSS_INDEX_RESPONSE, headers: {})
  file = 'spec/testdata/Gemfile.lock'
  deps = Chelsea::Deps.new({ path: Pathname.new(file) })
  deps.dependencies
end

def coordinates
  coordinates = {}
  coordinates['coordinates'] = []
  coordinates['coordinates'] << 'pkg:gem/chelsea@0.0.3'
  coordinates['coordinates'] << 'pkg:gem/diff-lcs@1.3.0'
  coordinates['coordinates'] << 'pkg:gem/domain_name@0.5.20190701'
  coordinates['coordinates'] << 'pkg:gem/equatable@0.6.1'
  coordinates
end

def dependency_hash # rubocop:disable Layout/MethodLength, Metrics/AbcSize
  dependency_hash = {}
  dependency_hash['addressable'] = ['addressable', '2.7.0']
  dependency_hash['chelsea'] = ['chelsea', '0.0.3']
  dependency_hash['crack'] = ['crack', '0.4.3']
  dependency_hash['diff-lcs'] = ['diff-lcs', '1.3.0']
  dependency_hash['domain_name'] = ['domain_name', '0.5.20190701']
  dependency_hash['equatable'] = ['equatable', '0.6.1']
  dependency_hash['hashdiff'] = ['hashdiff', '1.0.1']
  dependency_hash['http-cookie'] = ['http-cookie', '1.0.3']
  dependency_hash['mime-types'] = ['mime-types', '3.3.1']
  dependency_hash['mime-types-data'] = ['mime-types-data', '3.2019.1009']
  dependency_hash['netrc'] = ['netrc', '0.11.0']
  dependency_hash['pastel'] = ['pastel', '0.7.3']
  dependency_hash['public_suffix'] = ['public_suffix', '4.0.3']
  dependency_hash['rake'] = ['rake', '10.5.0']
  dependency_hash['rest-client'] = ['rest-client', '2.0.2']
  dependency_hash['rspec'] = ['rspec', '3.9.0']
  dependency_hash['rspec-core'] = ['rspec-core', '3.9.1']
  dependency_hash['rspec-expectations'] = ['rspec-expectations', '3.9.1']
  dependency_hash['rspec-mocks'] = ['rspec-mocks', '3.9.1']
  dependency_hash['rspec-support'] = ['rspec-support', '3.9.2']
  dependency_hash['rspec_junit_formatter'] = ['rspec_junit_formatter', '0.4.1']
  dependency_hash['safe_yaml'] = ['safe_yaml', '1.0.5']
  dependency_hash['slop'] = ['slop', '4.8.0']
  dependency_hash['tty-color'] = ['tty-color', '0.5.1']
  dependency_hash['tty-cursor'] = ['tty-cursor', '0.7.1']
  dependency_hash['tty-font'] = ['tty-font', '0.5.0']
  dependency_hash['tty-spinner'] = ['tty-spinner', '0.9.3']
  dependency_hash['unf'] = ['unf', '0.1.4']
  dependency_hash['unf_ext'] = ['unf_ext', '0.0.7.6']
  dependency_hash['webmock'] = ['webmock', '3.8.3']

  dependency_hash
end

OSS_INDEX_RESPONSE = %q(
  [
    {"coordinates":"pkg:gem/chelsea@0.0.3","reference":"https://ossindex.sonatype.org/component/pkg:gem/chelsea@0.0.3","vulnerabilities":[]},
    {"coordinates":"pkg:gem/diff-lcs@1.3.0","description":"Diff::LCS computes the difference between two Enumerable sequences using the\nMcIlroy-Hunt longest common subsequence (LCS) algorithm. It includes utilities\nto create a simple HTML diff output format and a standard diff-like tool.\n\nThis is release 1.3, providing a tentative fix to a long-standing issue related\nto incorrect detection of a patch direction. Also modernizes the gem\ninfrastructure, testing infrastructure, and provides a warning-free experience\nto Ruby 2.4 users.","reference":"https://ossindex.sonatype.org/component/pkg:gem/diff-lcs@1.3.0","vulnerabilities":[]},
    {"coordinates":"pkg:gem/domain_name@0.5.20190701","description":"This is a Domain Name manipulation library for Ruby.\n\nIt can also be used for cookie domain validation based on the Public\nSuffix List.\n","reference":"https://ossindex.sonatype.org/component/pkg:gem/domain_name@0.5.20190701","vulnerabilities":[]},
    {"coordinates":"pkg:gem/equatable@0.6.1","description":"Allows ruby objects to implement equality comparison and inspection methods. By including this module, a class indicates that its instances have explicit general contracts for `hash`, `==` and `eql?` methods.","reference":"https://ossindex.sonatype.org/component/pkg:gem/equatable@0.6.1","vulnerabilities":[]},
    {"coordinates":"pkg:gem/http-cookie@1.0.3","description":"HTTP::Cookie is a Ruby library to handle HTTP Cookies based on RFC 6265.  It has with security, standards compliance and compatibility in mind, to behave just the same as today's major web browsers.  It has builtin support for the legacy cookies.txt and the latest cookies.sqlite formats of Mozilla Firefox, and its modular API makes it easy to add support for a new backend store.","reference":"https://ossindex.sonatype.org/component/pkg:gem/http-cookie@1.0.3","vulnerabilities":[]},
    {"coordinates":"pkg:gem/mime-types@3.3.1","description":"The mime-types library provides a library and registry for information about\nMIME content type definitions. It can be used to determine defined filename\nextensions for MIME types, or to use filename extensions to look up the likely\nMIME type definitions.\n\nVersion 3.0 is a major release that requires Ruby 2.0 compatibility and removes\ndeprecated functions. The columnar registry format introduced in 2.6 has been\nmade the primary format; the registry data has been extracted from this library\nand put into {mime-types-data}[https://github.com/mime-types/mime-types-data].\nAdditionally, mime-types is now licensed exclusively under the MIT licence and\nthere is a code of conduct in effect. There are a number of other smaller\nchanges described in the History file.","reference":"https://ossindex.sonatype.org/component/pkg:gem/mime-types@3.3.1","vulnerabilities":[]},
    {"coordinates":"pkg:gem/mime-types-data@3.2019.1009","description":"mime-types-data provides a registry for information about MIME media type\ndefinitions. It can be used with the Ruby mime-types library or other software\nto determine defined filename extensions for MIME types, or to use filename\nextensions to look up the likely MIME type definitions.","reference":"https://ossindex.sonatype.org/component/pkg:gem/mime-types-data@3.2019.1009","vulnerabilities":[]},{"coordinates":"pkg:gem/netrc@0.11.0","description":"This library can read and update netrc files, preserving formatting including comments and whitespace.","reference":"https://ossindex.sonatype.org/component/pkg:gem/netrc@0.11.0","vulnerabilities":[]},
    {"coordinates":"pkg:gem/ox@2.13.2","description":"A fast XML parser and object serializer that uses only standard C lib.\n            \nOptimized XML (Ox), as the name implies was written to provide speed optimized\nXML handling. It was designed to be an alternative to Nokogiri and other Ruby\nXML parsers for generic XML parsing and as an alternative to Marshal for Object\nserialization. ","reference":"https://ossindex.sonatype.org/component/pkg:gem/ox@2.13.2","vulnerabilities":[]},
    {"coordinates":"pkg:gem/pastel@0.7.3","description":"Terminal strings styling with intuitive and clean API.","reference":"https://ossindex.sonatype.org/component/pkg:gem/pastel@0.7.3","vulnerabilities":[]},{"coordinates":"pkg:gem/rake@10.5.0","description":"Rake is a Make-like program implemented in Ruby. Tasks and dependencies are\nspecified in standard Ruby syntax.\nRake has the following features:\n  * Rakefiles (rake's version of Makefiles) are completely defined in standard Ruby syntax.\n    No XML files to edit. No quirky Makefile syntax to worry about (is that a tab or a space?)\n  * Users can specify tasks with prerequisites.\n  * Rake supports rule patterns to synthesize implicit tasks.\n  * Flexible FileLists that act like arrays but know about manipulating file names and paths.\n  * Supports parallel execution of tasks.\n","reference":"https://ossindex.sonatype.org/component/pkg:gem/rake@10.5.0","vulnerabilities":[]},
    {"coordinates":"pkg:gem/rest-client@2.0.2","description":"A simple HTTP and REST client for Ruby, inspired by the Sinatra microframework style of specifying actions: get, put, post, delete.","reference":"https://ossindex.sonatype.org/component/pkg:gem/rest-client@2.0.2","vulnerabilities":[]},
    {"coordinates":"pkg:gem/rspec@3.9.0","description":"BDD for Ruby","reference":"https://ossindex.sonatype.org/component/pkg:gem/rspec@3.9.0","vulnerabilities":[]},
    {"coordinates":"pkg:gem/rspec-core@3.9.1","description":"BDD for Ruby. RSpec runner and example groups.","reference":"https://ossindex.sonatype.org/component/pkg:gem/rspec-core@3.9.1","vulnerabilities":[]},
    {"coordinates":"pkg:gem/rspec-expectations@3.9.1","description":"rspec-expectations provides a simple, readable API to express expected outcomes of a code example.","reference":"https://ossindex.sonatype.org/component/pkg:gem/rspec-expectations@3.9.1","vulnerabilities":[]},
    {"coordinates":"pkg:gem/rspec-mocks@3.9.1","description":"RSpec's 'test double' framework, with support for stubbing and mocking","reference":"https://ossindex.sonatype.org/component/pkg:gem/rspec-mocks@3.9.1","vulnerabilities":[]},
    {"coordinates":"pkg:gem/rspec-support@3.9.2","description":"Support utilities for RSpec gems","reference":"https://ossindex.sonatype.org/component/pkg:gem/rspec-support@3.9.2","vulnerabilities":[]},
    {"coordinates":"pkg:gem/rspec_junit_formatter@0.4.1","description":"RSpec results that your continuous integration service can read.","reference":"https://ossindex.sonatype.org/component/pkg:gem/rspec_junit_formatter@0.4.1","vulnerabilities":[]},
    {"coordinates":"pkg:gem/slop@4.8.0","description":"A DSL for gathering options and parsing command line flags","reference":"https://ossindex.sonatype.org/component/pkg:gem/slop@4.8.0","vulnerabilities":[]},
    {"coordinates":"pkg:gem/tty-color@0.5.1","description":"Terminal color capabilities detection","reference":"https://ossindex.sonatype.org/component/pkg:gem/tty-color@0.5.1","vulnerabilities":[]},
    {"coordinates":"pkg:gem/tty-cursor@0.7.1","description":"The purpose of this library is to help move the terminal cursor around and manipulate text by using intuitive method calls.","reference":"https://ossindex.sonatype.org/component/pkg:gem/tty-cursor@0.7.1","vulnerabilities":[]},
    {"coordinates":"pkg:gem/tty-font@0.5.0","reference":"https://ossindex.sonatype.org/component/pkg:gem/tty-font@0.5.0","vulnerabilities":[]},
    {"coordinates":"pkg:gem/tty-spinner@0.9.3","description":"A terminal spinner for tasks that have non-deterministic time frame.","reference":"https://ossindex.sonatype.org/component/pkg:gem/tty-spinner@0.9.3","vulnerabilities":[]},
    {"coordinates":"pkg:gem/unf@0.1.4","description":"This is a wrapper library to bring Unicode Normalization Form support\nto Ruby/JRuby.\n","reference":"https://ossindex.sonatype.org/component/pkg:gem/unf@0.1.4","vulnerabilities":[]},
    {"coordinates":"pkg:gem/unf_ext@0.0.7.6","description":"Unicode Normalization Form support library for CRuby","reference":"https://ossindex.sonatype.org/component/pkg:gem/unf_ext@0.0.7.6","vulnerabilities":[]}
  ]
)
