require 'chelsea/gems'
require_relative '../spec_helper'

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report').
      to_return(status: 200, body: "", headers: {})
  end
end

RSpec.describe Chelsea::Gems do
  it "executes `gems` command successfully" do
    output = StringIO.new
    file = "Gemfile.lock"
    options = {}
    command = Chelsea::Gems.new(file, options)

    command.execute(output: output)

    expect(output.string).to eq("")
  end

  it "can handle requests to OSS Index" do
      file = "Gemfile.lock"
      options = {}
      command = Chelsea::Gems.new(file, options)

      command.get_vulns()
  end
end
