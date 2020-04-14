# frozen_string_literal: true

require_relative 'config'
require 'rest-client'
require_relative 'db'

module Chelsea
  class OSSIndex
    def initialize(oss_index_user_name: '', oss_index_user_token: '')
      @oss_index_user_name = oss_index_user_name
      @oss_index_user_token = oss_index_user_token
      @db = DB.new
    end

    # Makes REST calls to OSS for vulnerabilities 128 coordinates at a time
    # Checks cache and stores results in cache
    def get_vulns(coordinates)
      remaining_coordinates, server_response = @db.check_db_for_cached_values(coordinates)

      return unless remaining_coordinates['coordinates'].count.positive?

      chunked = {}
      remaining_coordinates['coordinates'].each_slice(128).to_a.each do |coords|
        chunked['coordinates'] = coords
        res_json = call_oss_index(chunked)
        server_response = server_response.concat(res_json)
        _save_values_to_db(res_json)
      end
      server_response
    end

    def call_oss_index(coords)
      r = _resource.post coords.to_json, _headers
      r.code == 200 ? JSON.parse(r.body) : {}
    end

    private

    def _headers
      { :content_type => :json, :accept => :json, 'User-Agent' => _user_agent }
    end

    def _resource
      if !@oss_index_user_name.empty? && !@oss_index_user_token.empty?
        RestClient::Resource.new _api_url, user: @oss_index_user_name, password: @oss_index_user_token
      else
        RestClient::Resource.new _api_url
      end
    end

    def _api_url
      'https://ossindex.sonatype.org/api/v3/component-report'
    end

    def _user_agent
      "chelsea/#{Chelsea::VERSION}"
    end
  end
end
