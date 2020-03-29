require 'chelsea/oss_index'
require_relative '../spec_helper'
require 'chelsea/oss_index_exception'

RSpec.describe Chelsea::OssIndex do
  it "returns an array of results from OSS Index when queried properly" do
    stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report').
      to_return(status: 200, body: OSS_INDEX_RESPONSE, headers: {})

    file = "Gemfile.lock"
    options = Hash.new
    options[:db_file_name] = 'chelsea-test.pstore'
    ossindex = Chelsea::OssIndex.new(options)

    ossindex.clear_db_cache()

    server_response = ossindex.query_ossindex_for_vulns(get_coordinates())
    expect(server_response.count()).to eq(25)
  end

  it "handles a 404 response from the remote adequately" do
    stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report').
      to_return(status: 404)

    file = "Gemfile.lock"
    options = Hash.new
    options[:db_file_name] = 'chelsea-test.pstore'
    ossindex = Chelsea::OssIndex.new(options)

    ossindex.clear_db_cache()

    expect{ossindex.query_ossindex_for_vulns(get_coordinates())}.to raise_error(Chelsea::OssIndexException, "Error getting data from OSS Index server: .")
  end

  it "handles a 400 response from the remote adequately" do
    stub_request(:post, 'https://ossindex.sonatype.org/api/v3/component-report').
      to_return(status: 400, body: "Ill formed coordinates")

    file = "Gemfile.lock"
    options = Hash.new
    options[:db_file_name] = 'chelsea-test.pstore'
    ossindex = Chelsea::OssIndex.new(options)

    ossindex.clear_db_cache()

    expect{ossindex.query_ossindex_for_vulns(get_coordinates())}.to raise_error(Chelsea::OssIndexException, "Error getting data from OSS Index server: Ill formed coordinates.")
  end
end