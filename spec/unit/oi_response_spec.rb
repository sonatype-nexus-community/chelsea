
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

require 'chelsea/oi_response'
require 'spec_helper'

RSpec.describe Chelsea::OIResponse do
  context 'with defaults' do
    before(:all) do
      @oss_response = Chelsea::OIResponse.new(JSON.parse(oss_index_response))
    end

    it 'should instantiate the OSS Index response' do
      expect(@oss_response.class).to eq Chelsea::OIResponse
    end

    it 'should be able to count the number of dependencies' do
      expect(@oss_response.dep_count.class).to eq Integer
    end

    it 'should be able to count the number of vulnerabilities' do
      expect(@oss_response.vuln_count.class).to eq Integer
    end
  end
end
