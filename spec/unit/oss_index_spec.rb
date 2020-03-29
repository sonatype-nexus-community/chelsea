require 'chelsea/oss_index'
require_relative '../spec_helper'

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report').
      to_return(status: 200, body: OSS_INDEX_RESPONSE, headers: {})
  end
end

RSpec.describe Chelsea::OssIndex do
  it "returns an array of results from OSS Index when queried properly" do
    file = "Gemfile.lock"
    options = Hash.new
    options[:db_file_name] = 'chelsea-test.pstore'
    ossindex = Chelsea::OssIndex.new(options)

    ossindex.clear_db_cache()

    server_response = ossindex.query_ossindex_for_vulns(get_coordinates())
    expect(server_response.count()).to eq(25)
  end
end