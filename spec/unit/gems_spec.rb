require 'chelsea/gems'
require 'spec_helper'

RSpec.describe Chelsea::Gems do
  describe "when talking to OSS Index" do
    before(:all) {
      stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report').
      to_return(status: 200, body: OSS_INDEX_RESPONSE, headers: {})
    }
    context 'given a valid Gemfile.lock' do
      file = "spec/testdata/Gemfile.lock"
      it "can collect dependencies, query, and print results" do
        output = StringIO.new
        command = Chelsea::Gems.new(file: file)
        command.execute(output: output)
        expect(output.string).to eq("")
      end
    end
  end
  context 'given an invalid Gemfile.lock' do
    file = "spec/Gemfile.lock"
    it "will exit with a RuntimeError" do
      expect{Chelsea::Gems.new(file: file)}.to raise_error(RuntimeError, "Gemfile.lock not found, check --file path")
    end
  end


end
