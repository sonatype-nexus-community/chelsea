require 'rest-client'
require 'json'

module Chelsea
  class IQClient

    def initialize(public_application_id, server_url, username, auth_token)
      @public_application_id, @server_url, @username, @auth_token = public_application_id, server_url, username, auth_token
    end

    def submit_sbom(sbom)
      user_agent = user_agent
      resource = RestClient::Resource.new _api_url, :user => self.username, :password => self.auth_token
      resource.post sbom.to_s, _headers
    end

    def status_url(res)
      res_json = JSON.parse(res.body)
      res['statusUrl']
    end

    private

    def _headers
      { 'User-Agent' => "chelsea/#{Chelsea::VERSION}" }
    end

    def _api_url
      "#{@server_url}/api/v2/scan/applications/#{@public_application_id}/sources/chelsea"
    end
  end
end