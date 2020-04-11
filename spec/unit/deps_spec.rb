require 'chelsea/deps'
require 'spec_helper'

RSpec.describe Chelsea::Deps do
  context 'given a valid Gemfile.lock' do
    file = 'spec/testdata/Gemfile.lock'
    it 'can collect dependencies' do
      stub_oss_response
      deps = process_deps_from_gemfile(file)
      expect(deps.dependencies.class).to eq(Hash)
      expect(deps.dependencies.empty?).to eq(false)
    end

    it 'can generate a valid coordinates object for OSS Index' do
      stub_oss_response
      deps = process_deps_from_gemfile(file)
      coordinates = deps.coordinates.to_h

      expect(coordinates.class).to eq(Hash)
      expect(coordinates.empty?).to eq(false)
      expect(coordinates['coordinates'].size).to eq(30)
      expect(coordinates['coordinates'][0]).to eq('pkg:gem/addressable@2.7.0')
      expect(coordinates['coordinates'][1]).to eq('pkg:gem/chelsea@0.0.3')
      expect(coordinates['coordinates'][2]).to eq('pkg:gem/crack@0.4.3')
    end
  end
  context 'given an invalid path' do
    file = 'invalid/path'
    it 'raises a RuntimeError with a message indicatingw invalid file path' do
      expect{ process_deps_from_gemfile(file) }
        .to raise_error(
          RuntimeError,
          'Gemfile.lock not parseable, please check file or that it\'s path is valid'
        )
    end
  end

  it 'can turn a name and version into a valid purl' do
    expect(Chelsea::Deps.to_purl('name-thing', '1.0.0'))
      .to eq('pkg:gem/name-thing@1.0.0')
  end
end
