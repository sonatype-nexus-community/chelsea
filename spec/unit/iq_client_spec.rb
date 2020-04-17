require 'chelsea'
require 'spec_helper'

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
        expect(@client.post_sbom(bom)).to eq true
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
      expect(@client.post_sbom(bom)).to eq true
    end
  end
  context 'with a configuration file' do
    # Check that configuration files get set
  end
  context 'with a config file and cli arguments' do
    # Check that cli args override config
  end
end
