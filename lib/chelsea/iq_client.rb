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

require_relative 'spinner'

module Chelsea
  # class to poll Nexus IQ with gathered dependencies
  class IQClient
    DEFAULT_OPTIONS = {
      public_application_id: 'testapp',
      server_url: 'http://localhost:8070',
      username: 'admin',
      auth_token: 'admin123',
      internal_application_id: ''
    }
    def initialize(options: DEFAULT_OPTIONS)
      @options = options
      @pastel = Pastel.new
      @spinner = Chelsea::Spinner.new
    end

    def post_sbom(sbom)
      spin = @spinner.spin_msg 'Submitting sbom to Nexus IQ Server'
      @internal_application_id = _get_internal_application_id
      resource = RestClient::Resource.new(
        _api_url,
        user: @options[:username],
        password: @options[:auth_token]
      )
      res = resource.post(
        sbom.to_s,
        _headers.merge(content_type: 'application/xml')
      )
      if res.code == 202
        spin.stop('...request failed.')
        nil
      else
        spin.success('...done.')
        status_url(res)
      end
    end

    def status_url(res)
      res = JSON.parse(res.body)
      res['statusUrl']
    end

    def poll_status(url)
      # Pretty horiffic polling. Let's do a backoff algo
      spin = @spinner.spin_msg 'Polling Nexus IQ Server for results'
      loop do
        begin
          res = _poll_iq_server(url)
          if res.code == 200
            spin.success('...done.')
            _handle_response(res)
            break
          end
        rescue StandardError => _e
          sleep(1)
        end
      end
    end

    def status(status_url)
      resource = RestClient::Resource.new(
        "#{@options[:server_url]}/#{status_url}",
        user: @options[:username],
        password: @options[:auth_token]
      )
      resource.get _headers
    end

    private

    def _handle_response(res)
      res = JSON.parse(res.body)
      if res['policyAction'] == 'Failure'
        _failure_response
      else
        _success_response
      end
    end

    def _success_response
      puts @pastel.white.bold(
        'Hi! Chelsea here, no policy violations for this audit!'
      )
      puts @pastel.white.bold("Report URL: #{res['reportHtmlUrl']}")
      exit 0
    end

    def _failure_response
      puts @pastel.red.bold(
        'Hi! Chelsea here, you have some policy violations to clean up!'
      )
      puts @pastel.red.bold("Report URL: #{res['reportHtmlUrl']}")
      exit 1
    end

    def _poll_iq_server(status_url)
      resource = RestClient::Resource.new(
        "#{@options[:server_url]}/#{status_url}",
        user: @options[:username],
        password: @options[:auth_token]
      )

      resource.get _headers
    end

    def _poll_status
      # Pretty horiffic polling. Let's do a backoff algo
      # we have two poll status methods. Consolidate
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

    def _user_agent
      "chelsea/#{Chelsea::VERSION}"
    end

    def _api_url
      "#{@options[:server_url]}"\
      '/api/v2/scan/applications/'\
      "#{@internal_application_id}/sources/chelsea"
    end

    def _internal_application_id_api_url
      "#{@options[:server_url]}"\
      '/api/v2/applications'\
      "?publicId=#{@options[:public_application_id]}"
    end
  end
end
