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

require 'chelsea'
require 'spec_helper'
require 'byebug'

RSpec.describe Chelsea::IQClient do

  context 'with defaults' do
    before(:all) {
      @client = Chelsea::IQClient.new
    }
    it 'should instantiate the client' do
      expect(@client.class).to eq Chelsea::IQClient
    end
    context 'with an generated dependencies sbom' do
      it 'should be able to submit an sbom' do
        bom = Chelsea::Bom.new(get_test_dependencies)
        stub_iq_response
        stub_sbom
        expect(@client.post_sbom(bom)).to eq "api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/status/9cee2b6366fc4d328edc318eae46b2cb"
      end
    end
    # Check that defaults get set
  end
  context 'with cli arguments' do
    before(:all) {
      @opts = {
        public_application_id: 'appid',
        server_url: 'server_url',
        username: 'iquser',
        auth_token: 'iqpass'
      }
      @client = Chelsea::IQClient.new(options: @opts)
    }
    it 'should be able to submit an sbom' do
      bom = Chelsea::Bom.new(get_test_dependencies)
      stub_iq_response(**@opts)
      stub_sbom(**@opts)
      expect(@client.post_sbom(bom)).to eq "api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/status/9cee2b6366fc4d328edc318eae46b2cb"
    end
  end
end
