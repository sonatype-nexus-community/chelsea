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

require 'rest-client'
require 'json'
require 'pastel'
require 'uri'

require_relative 'spinner'

module Chelsea
  # IQ audit operations
  class IQClient # rubocop:disable Metrics/ClassLength
    # SECURITY: Removed hardcoded default credentials (CWE-798)
    # All credentials must now be explicitly provided
    DEFAULT_OPTIONS = {
      public_application_id: nil,
      server_url: nil,
      username: nil,
      auth_token: nil,
      internal_application_id: '',
      stage: 'build'
    }.freeze

    # Maximum number of polling attempts before timeout
    MAX_POLL_RETRIES = 300
    # Seconds to wait between poll attempts
    POLL_INTERVAL = 1

    def initialize(options: {})
      @options = DEFAULT_OPTIONS.merge(options)
      _validate_required_options!
      @pastel = Pastel.new
      @spinner = Chelsea::Spinner.new
    end

    def post_sbom(sbom) # rubocop:disable Metrics/MethodLength
      spin = @spinner.spin_msg 'Submitting sbom to Nexus IQ Server'
      @internal_application_id = _get_internal_application_id
      resource = RestClient::Resource.new(
        _api_url,
        user: @options[:username],
        password: @options[:auth_token]
      )
      res = resource.post sbom.to_s, _headers.merge(content_type: 'application/xml')
      if res.code == 202
        spin.success('...done.')
        status_url(res)
      else
        spin.stop('...request failed.')
        nil
      end
    end

    def status_url(res)
      res = JSON.parse(res.body)
      res['statusUrl']
    end

    # SECURITY: Added timeout to prevent infinite loop (CWE-835)
    def poll_status(url) # rubocop:disable Metrics/MethodLength
      spin = @spinner.spin_msg 'Polling Nexus IQ Server for results'
      retries = 0
      loop do
        res = _poll_iq_server(url)
        if res.code == 200
          spin.success('...done.')
          return _handle_response(res)
        end
      rescue StandardError => e
        retries += 1
        if retries >= MAX_POLL_RETRIES
          spin.error('...timeout.')
          raise "Polling timeout after #{MAX_POLL_RETRIES} attempts: #{e.message}"
        end
        sleep(POLL_INTERVAL)
      end
    end

    # colors to use when printing message
    COLOR_FAILURE = 31
    COLOR_WARNING = 33 # want yellow, but doesn't appear to print
    COLOR_NONE = 32
    # Known policy actions
    POLICY_ACTION_FAILURE = 'Failure'
    POLICY_ACTION_WARNING = 'Warning'
    POLICY_ACTION_NONE = 'None'

    private

    # SECURITY: Validate required options are provided
    def _validate_required_options!
      missing = []
      missing << 'server_url' if @options[:server_url].nil? || @options[:server_url].empty?
      missing << 'username' if @options[:username].nil? || @options[:username].empty?
      missing << 'auth_token' if @options[:auth_token].nil? || @options[:auth_token].empty?
      missing << 'public_application_id' if @options[:public_application_id].nil? || @options[:public_application_id].empty?

      return if missing.empty?

      raise ArgumentError, "Missing required IQ Server options: #{missing.join(', ')}. " \
                           'Please provide --iquser, --iqpass, --server, and --application options.'
    end

    def _handle_response(res) # rubocop:disable Metrics/MethodLength
      res = JSON.parse(res.body)
      # get absolute report url
      absolute_report_html_url = URI.join(@options[:server_url], res['reportHtmlUrl'])

      case res['policyAction']
      when POLICY_ACTION_FAILURE
        ['Hi! Chelsea here, you have some policy violations to clean up!'\
          "\nReport URL: #{absolute_report_html_url}",
         COLOR_FAILURE, 1]
      when POLICY_ACTION_WARNING
        ['Hi! Chelsea here, you have some policy warnings to peck at!'\
        "\nReport URL: #{absolute_report_html_url}",
         COLOR_WARNING, 0]
      when POLICY_ACTION_NONE
        ['Hi! Chelsea here, no policy violations for this audit!'\
        "\nReport URL: #{absolute_report_html_url}",
         COLOR_NONE, 0]
      else
        ['Hi! Chelsea here, no policy violations for this audit, but unknown policy action!'\
        "\nReport URL: #{absolute_report_html_url}",
         COLOR_FAILURE, 1]
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

    def _poll_status # rubocop:disable Metrics/MethodLength
      return unless @status_url

      loop do
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

    def _get_internal_application_id # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      resource = RestClient::Resource.new(
        _internal_application_id_api_url,
        user: @options[:username],
        password: @options[:auth_token]
      )
      res = resource.get _headers
      if res.code != 200
        puts "failure reading application id: #{@options[:public_application_id]}. response status: #{res.code}"
        return
      end
      body = JSON.parse(res)
      if body['applications'].empty?
        puts "failed to get internal application id for IQ application id: #{@options[:public_application_id]}"
        return
      end
      body['applications'][0]['id']
    end

    def _headers
      { 'User-Agent' => _user_agent }
    end

    def _api_url
      # rubocop:disable Layout/LineLength
      "#{@options[:server_url]}/api/v2/scan/applications/#{@internal_application_id}/sources/chelsea?stageId=#{@options[:stage]}"
      # rubocop:enable Layout/LineLength
    end

    def _internal_application_id_api_url
      "#{@options[:server_url]}/api/v2/applications?publicId=#{@options[:public_application_id]}"
    end

    def _user_agent
      "chelsea/#{Chelsea::VERSION}"
    end
  end
end
