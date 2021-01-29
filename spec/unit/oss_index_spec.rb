# frozen_string_literal: true

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

require 'chelsea/oss_index'
require 'spec_helper'

RSpec.describe Chelsea::OSSIndex do
  context 'with defaults' do
    before(:all) do
      @oss = Chelsea::OSSIndex.new
    end
    it 'should instantiate the OSS Index client' do
      expect(@oss.class).to eq Chelsea::OSSIndex
    end
    # Check that defaults get set
  end
  context 'with cli arguments' do
    # Check that cli args get set
  end
  context 'with a configuration file' do
    # Check that configuration files get set
  end
  context 'with a config file and cli arguments' do
    # Check that cli args override config
  end
end
