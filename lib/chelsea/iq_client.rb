require 'rest-client'
require 'json'
require 'pastel'

require_relative 'spinner'

module Chelsea
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
      spin = @spinner.spin_msg "Submitting sbom to Nexus IQ Server"
      @internal_application_id = _get_internal_application_id
      resource = RestClient::Resource.new(
        _api_url,
        user: @options[:username],
        password: @options[:auth_token]
      )
      res = resource.post sbom.to_s, _headers.merge(content_type: 'application/xml')
      unless res.code != 202
        spin.success("...done.")
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

    def poll_status(url)
      spin = @spinner.spin_msg "Polling Nexus IQ Server for results"
      loop do
        begin
          res = _poll_iq_server(url)
          if res.code == 200
            spin.success("...done.")
            _handle_response(res)
            break
          end
        rescue
          sleep(1)
        end
      end
    end

    private

    def _handle_response(res)
      res = JSON.parse(res.body)
      unless res['policyAction'] == 'Failure'
        puts @pastel.white.bold("Hi! Chelsea here, no policy violations for this audit!")
        puts @pastel.white.bold("Report URL: #{res['reportHtmlUrl']}")
        exit 0
      else
        puts @pastel.red.bold("Hi! Chelsea here, you have some policy violations to clean up!")
        puts @pastel.red.bold("Report URL: #{res['reportHtmlUrl']}")
        exit 1
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
      res = JSON.parse(resource.get(_headers))
      res['applications'][0]['id']
    end

    def _headers
      { 'User-Agent' => _user_agent }
    end

    def _api_url
      "#{@options[:server_url]}/api/v2/scan/applications/#{@internal_application_id}/sources/chelsea"
    end

    def _internal_application_id_api_url
      "#{@options[:server_url]}/api/v2/applications?publicId=#{@options[:public_application_id]}"
    end

    def _user_agent
      "chelsea/#{Chelsea::VERSION}"
    end
  end
end
