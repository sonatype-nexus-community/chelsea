require 'rest-client'
require 'json'

module Chelsea
  class IQClient

    def initialize(public_application_id, server_url, username, auth_token)
      @public_application_id, @server_url, @username, @auth_token = public_application_id, server_url, username, auth_token
      @@internal_application_id = ""
    end

    def submit_sbom(sbom)
      _get_internal_application_id()
      user_agent = user_agent
      resource = RestClient::Resource.new _api_url, :user => @username, :password => @auth_token
      resource.post sbom.to_s, _headers
    end

    def status_url(res)
      res_json = JSON.parse(res.body)
      res['statusUrl']
    end

    private

    def _get_internal_application_id()
      user_agent = user_agent
      resource = RestClient::Resource.new _internal_application_id_api_url, :user => @username, :password => @auth_token
      res = JSON.parse(resource.get _headers)

      @@internal_application_id = res["applications"][0]["id"]
    end

    def _headers
      { 'User-Agent' => "chelsea/#{Chelsea::VERSION}",
        'Content-Type' => "application/xml" }
    end

    def _headers_without_content_type
      { 'User-Agent' => "chelsea/#{Chelsea::VERSION}" }
    end

    def _api_url
      "#{@server_url}/api/v2/scan/applications/#{@@internal_application_id}/sources/chelsea"
    end

    def _internal_application_id_api_url
      "#{@server_url}/api/v2/applications?publicId=#{@public_application_id}"
    end

  end
end