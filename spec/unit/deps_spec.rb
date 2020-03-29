require 'chelsea/deps'
require_relative '../spec_helper'

RSpec.describe Chelsea::Deps do
  it "can collect dependencies given a valid Gemfile.lock" do
    output = StringIO.new
    file = "spec/testdata/Gemfile.lock"
    deps = Chelsea::Deps.new({path: Pathname.new(file)})

    dependencies = deps.get_dependencies()

    expect(dependencies.class).to eq(Hash)
    expect(dependencies.empty?).to eq(false)
  end

  it "can turn a dependencies hash into a valid coordinates object for OSS Index" do
    output = StringIO.new
    file = "spec/testdata/Gemfile.lock"
    deps = Chelsea::Deps.new({path: Pathname.new(file)})

    coordinates = deps.get_dependencies_versions_as_coordinates(get_dependency_hash())

    expect(coordinates.class).to eq(Hash)
    expect(coordinates.empty?).to eq(false)
    expect(coordinates["coordinates"].size).to eq(30)
    expect(coordinates["coordinates"][0]).to eq("pkg:gem/addressable@2.7.0")
    expect(coordinates["coordinates"][15]).to eq("pkg:gem/rspec@3.9.0")
    expect(coordinates["coordinates"][29]).to eq("pkg:gem/webmock@3.8.3")
  end
end
