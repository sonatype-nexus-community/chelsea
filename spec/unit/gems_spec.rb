require 'chelsea/gems'
require_relative '../spec_helper'

RSpec.describe Chelsea::Gems do
  describe "when talking to OSS Index" do
    before(:all) {
      stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report').
      to_return(status: 200, body: OSS_INDEX_RESPONSE, headers: {})
    }

    it "can collect dependencies, query, and print results" do
      output = StringIO.new
      file = "spec/testdata/Gemfile.lock"
      command = Chelsea::Gems.new(file)

      command.execute(output: output)

      expect(output.string).to eq("")
    end
  end

  it "will exit if a invalid Gemfile.lock is passed" do
    output = StringIO.new
    file = "spec/Gemfile.lock"
    expect{Chelsea::Gems.new(file)}.to raise_error(RuntimeError, "Gemfile.lock not found, check --file path")
  end
end
