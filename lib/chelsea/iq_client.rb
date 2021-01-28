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

require 'rest-client'
require 'json'
require 'pastel'
require 'uri'

require_relative 'spinner'

module Chelsea
  class IQClient

    DEFAULT_OPTIONS = {
      public_application_id: 'testapp',
      server_url: 'http://localhost:8070',
      username: 'admin',
      auth_token: 'admin123',
      internal_application_id: '',
      stage: 'build'
    }

    def initialize(options: DEFAULT_OPTIONS)
      @options = options
      @pastel = Pastel.new
      @spinner = Chelsea::Spinner.new
    end

    def post_sbom(sbom)
      spin = @spinner.spin_msg "Submitting sbom to Nexus IQ Server"
      @internal_application_id = _get_internal_application_id
      resource = RestClient::Resource.new(
        _api_url,
        user: @options[:username],
        password: @options[:auth_token]
      )
      res = resource.post sbom.to_s, _headers.merge(content_type: 'application/xml')
      if res.code != 202
        spin.stop('...request failed.')
        nil
      else
        spin.success("...done.")
        status_url(res)
      end
    end

    def status_url(res)
      res = JSON.parse(res.body)
      res['statusUrl']
    end

    def poll_status(url)
      spin = @spinner.spin_msg "Polling Nexus IQ Server for results"
      loop do
        begin
          res = _poll_iq_server(url)
          if res.code == 200
            spin.success("...done.")
            return _handle_response(res)
          end
        rescue
          sleep(1)
        end
      end
    end

    # colors to use when printing message
    COLOR_FAILURE = 31
    COLOR_WARNING = 30 # want yellow, but doesn't appear to print
    COLOR_NONE = 32
    # Known policy actions
    POLICY_ACTION_FAILURE = 'Failure'
    POLICY_ACTION_WARNING = 'Warning'
    POLICY_ACTION_NONE = 'None'

    private

    def _handle_response(res)
      res = JSON.parse(res.body)
      # get absolute report url
      absolute_report_html_url = URI.join(@options[:server_url], res['reportHtmlUrl'])

      case res['policyAction']
      when POLICY_ACTION_FAILURE
        return "Hi! Chelsea here, you have some policy violations to clean up!"\
          "\nReport URL: #{absolute_report_html_url}",
          COLOR_FAILURE, 1
      when POLICY_ACTION_WARNING
        return "Hi! Chelsea here, you have some policy warnings to peck at!"\
        "\nReport URL: #{absolute_report_html_url}",
          COLOR_WARNING, 0
      when POLICY_ACTION_NONE
        return "Hi! Chelsea here, no policy violations for this audit!"\
        "\nReport URL: #{absolute_report_html_url}",
          COLOR_NONE, 0
      else
        return "Hi! Chelsea here, no policy violations for this audit, but unknown policy action!"\
        "\nReport URL: #{absolute_report_html_url}",
          COLOR_FAILURE, 1
      end
    end

    def _poll_iq_server(status_url)
      resource = RestClient::Resource.new(
        "#{@options[:server_url]}/#{status_url}",
        user: @options[:username],
        password: @options[:auth_token]
      )

      resource.get _headers
    end

    def status(status_url)
      resource = RestClient::Resource.new(
        "#{@options[:server_url]}/#{status_url}",
        user: @options[:username],
        password: @options[:auth_token]
      )
      resource.get _headers
    end

    def _status_url(res)
      res = JSON.parse(res.body)
      res['statusUrl']
    end

    private

    def _poll_status
      return unless @status_url

      loop do
        begin
          res = check_status(@status_url)
          if res.code == 200
            puts JSON.parse(res.body)
            break
          end
        rescue RestClient::ResourceNotFound => _e
          print '.'
          sleep(1)
        end
      end
    end

    def _get_internal_application_id
      resource = RestClient::Resource.new(
        _internal_application_id_api_url,
        user: @options[:username],
        password: @options[:auth_token]
      )
      res = resource.get _headers
      body = JSON.parse(res)
      body['applications'][0]['id']
    end

    def _headers
      { 'User-Agent' => _user_agent }
    end

    def _api_url
      "#{@options[:server_url]}/api/v2/scan/applications/#{@internal_application_id}/sources/chelsea?stageId=#{@options[:stage]}"
    end

    def _internal_application_id_api_url
      "#{@options[:server_url]}/api/v2/applications?publicId=#{@options[:public_application_id]}"
    end

    def _user_agent
      "chelsea/#{Chelsea::VERSION}"
    end
  end
end
