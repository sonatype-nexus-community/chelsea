#
# Copyright 2019-Present Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chelsea/deps'
require 'spec_helper'

RSpec.describe Chelsea::Deps do
  context 'given a valid Gemfile.lock' do
    before(:all) do
      stub_oss_response
      file = 'spec/testdata/Gemfile.lock'
      @dependencies, @reverse_dependencies, @coordinates = process_deps_from_gemfile(file)
    end
    it 'can collect dependencies' do
      expect(@dependencies.class).to eq(Hash)
      expect(@dependencies.empty?).to eq(false)
    end

    it 'can generate a valid coordinates object for OSS Index' do
      expect(@coordinates.class).to eq(Hash)
      expect(@coordinates.empty?).to eq(false)
      expect(@coordinates['coordinates'].size).to eq(30)
      expect(@coordinates['coordinates'][0]).to eq('pkg:gem/addressable@2.7.0')
      expect(@coordinates['coordinates'][1]).to eq('pkg:gem/chelsea@0.0.3')
      expect(@coordinates['coordinates'][2]).to eq('pkg:gem/crack@0.4.3')
    end
  end
  context 'given an invalid path' do
    file = 'invalid/path'
    it 'raises a RuntimeError with a message indicating invalid file path' do
      expect { process_deps_from_gemfile(file) }
        .to raise_error(
          Errno::ENOENT,
          'No such file or directory @ rb_sysopen - invalid/path'
        )
    end
  end

  it 'can turn a name and version into a valid purl' do
    expect(Chelsea::Deps.to_purl('name-thing', '1.0.0'))
      .to eq('pkg:gem/name-thing@1.0.0')
  end
end
