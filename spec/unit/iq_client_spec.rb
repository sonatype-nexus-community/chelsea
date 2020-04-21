require 'chelsea'
require 'spec_helper'
require 'byebug'

RSpec.describe Chelsea::IQClient do

  context 'with defaults' do
    before(:all) {
      @client = Chelsea::IQClient.new
    }
    it 'should instantiate the client' do
      expect(@client.class).to eq Chelsea::IQClient
    end
    context 'with an generated dependencies sbom' do
      it 'should be able to submit an sbom' do
        deps = get_test_dependencies
        bom = Chelsea::Bom.new(deps)
        stub_iq_response
        stub_sbom
        expect(@client.post_sbom(bom)).to eq "api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/status/9cee2b6366fc4d328edc318eae46b2cb"
      end
    end
    # Check that defaults get set
  end
  context 'with cli arguments' do
    before(:all) {
      @opts = {
        public_application_id: 'appid',
        server_url: 'server_url',
        username: 'iquser',
        auth_token: 'iqpass'
      }
      @client = Chelsea::IQClient.new(options: @opts)
    }
    it 'should be able to submit an sbom' do
      deps = get_test_dependencies
      bom = Chelsea::Bom.new(deps)
      stub_iq_response(**@opts)
      stub_sbom(**@opts)
      expect(@client.post_sbom(bom)).to eq "api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/status/9cee2b6366fc4d328edc318eae46b2cb"
    end
  end
end
