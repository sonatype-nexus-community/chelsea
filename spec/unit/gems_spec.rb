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

require 'chelsea/gems'
require 'spec_helper'

RSpec.describe Chelsea::Gems do
  before(:all) {
    stub_oss_response
  }

  describe 'when talking to OSS Index' do
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
