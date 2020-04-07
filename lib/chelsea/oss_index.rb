require_relative 'config'
require 'rest-client'

module Chelsea
  class OSSIndex
    
    def initialize(oss_index_user_name: "", oss_index_user_token: "")
      if oss_index_user_name.empty? || oss_index_user_token.empty?
        config = Chelsea::Config.new().get_oss_index_config()
        @oss_index_user_name, @oss_index_user_token = config["Username"], config["Token"]
      else
        @oss_index_user_name, @oss_index_user_token = oss_index_user_name, oss_index_user_token
      end
    end

    def call_oss_index(coords)
      r = _resource.post coords.to_json, _headers
      if r.code == 200
        JSON.parse(r.body)
      end
    end

    private

    def _headers
      { :content_type => :json, :accept => :json, 'User-Agent' => _user_agent }
    end

    def _resource
      if !@oss_index_user_name.empty? && !@oss_index_user_token.empty?
        RestClient::Resource.new _api_url, :user => @oss_index_user_name, :password => @oss_index_user_token
      else
        RestClient::Resource.new _api_url
      end
    end

    def _api_url
      "https://ossindex.sonatype.org/api/v3/component-report"
    end

    def _user_agent
      "chelsea/#{Chelsea::VERSION}"
    end

  end
end