require 'chelsea/deps'
require_relative '../spec_helper'

RSpec.describe Chelsea::Deps do
  before do
    @dep_hash = get_dependency_hash
  end
  it "can collect dependencies given a valid Gemfile.lock" do
    output = StringIO.new
    file = "spec/testdata/Gemfile.lock"
    stub_request(:post, "https://ossindex.sonatype.org/api/v3/component-report").
    with(
       body: "{\"coordinates\":[\"pkg:gem/addressable@2.7.0\",\"pkg:gem/crack@0.4.3\",\"pkg:gem/hashdiff@1.0.1\",\"pkg:gem/public_suffix@4.0.3\",\"pkg:gem/safe_yaml@1.0.5\",\"pkg:gem/webmock@3.8.3\"]}",
       headers: {
       'Accept'=>'application/json',
       'Accept-Encoding'=>'gzip, deflate',
       'Content-Length'=>'172',
       'Content-Type'=>'application/json',
       'Host'=>'ossindex.sonatype.org',
       'User-Agent'=>'chelsea/0.0.3'
     }).to_return(status: 200, body: OSS_INDEX_RESPONSE, headers: {})

    deps = Chelsea::Deps.new({path: Pathname.new(file)})
    deps.audit

    expect(deps.to_h.class).to eq(Hash)
    expect(deps.to_h.empty?).to eq(false)
  end

  it "can turn a dependencies hash into a valid coordinates object for OSS Index" do
    output = StringIO.new
    file = "spec/testdata/Gemfile.lock"
    stub_request(:post, "https://ossindex.sonatype.org/api/v3/component-report").
         with(
            body: "{\"coordinates\":[\"pkg:gem/addressable@2.7.0\",\"pkg:gem/crack@0.4.3\",\"pkg:gem/hashdiff@1.0.1\",\"pkg:gem/public_suffix@4.0.3\",\"pkg:gem/safe_yaml@1.0.5\",\"pkg:gem/webmock@3.8.3\"]}",
            headers: {
            'Accept'=>'application/json',
            'Accept-Encoding'=>'gzip, deflate',
            'Content-Length'=>'172',
            'Content-Type'=>'application/json',
            'Host'=>'ossindex.sonatype.org',
            'User-Agent'=>'chelsea/0.0.3'
          }).to_return(status: 200, body: OSS_INDEX_RESPONSE, headers: {})
    deps = Chelsea::Deps.new({path: Pathname.new(file)})
    deps.audit

    coordinates = deps.coordinates.to_h

    expect(coordinates.class).to eq(Hash)
    expect(coordinates.empty?).to eq(false)
    expect(coordinates["coordinates"].size).to eq(6)
    expect(coordinates["coordinates"][0]).to eq("pkg:gem/addressable@2.7.0")
    expect(coordinates["coordinates"][1]).to eq("pkg:gem/crack@0.4.3")
    expect(coordinates["coordinates"][2]).to eq("pkg:gem/hashdiff@1.0.1")
  end

  it "will raises a RuntimeError with a custom message with an invalid file path" do
    output = StringIO.new
    file = "invalid/path"
    expect{Chelsea::Deps.new({path: Pathname.new(file)})}.to raise_error(RuntimeError, "Gemfile.lock not parseable, please check file or that it's path is valid")
  end

  it "can turn a name and version into a valid purl" do
    expect(Chelsea::Deps.to_purl("name-thing", "1.0.0")).to eq("pkg:gem/name-thing@1.0.0")
  end
end
