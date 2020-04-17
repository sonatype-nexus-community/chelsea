require 'chelsea/gems'
require 'spec_helper'

RSpec.describe Chelsea::Gems do
  describe 'when talking to OSS Index' do
    before(:all) {
      stub_oss_response
    }
    context 'given a valid Gemfile.lock' do
      file = 'spec/testdata/Gemfile.lock'
      it 'can collect dependencies, query, and print results' do
        command = Chelsea::Gems.new(file: file)
        expect { command.execute }.to_not raise_error
      end
    end
  end
  context 'given an invalid Gemfile.lock' do
    file = 'spec/Gemfile.lock'
    it 'will exit with a RuntimeError' do
      expect{ Chelsea::Gems.new(file: file) }
        .to raise_error(
          RuntimeError,
          'Gemfile.lock not found, check --file path'
        )
    end
  end
end
