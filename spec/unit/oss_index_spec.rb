require 'chelsea/oss_index'
require 'spec_helper'

RSpec.describe Chelsea::OSSIndex do
  context 'with defaults' do
    before(:all) {
      @oss = Chelsea::OSSIndex.new
    }
    it 'should instantiate the OSS Index client' do
      expect(@oss.class).to eq Chelsea::OSSIndex
    end
    # Check that defaults get set
  end
  context 'with cli arguments' do
    # Check that cli args get set
  end
  context 'with a configuration file' do
    # Check that configuration files get set
  end
  context 'with a config file and cli arguments' do
    # Check that cli args override config
  end
end