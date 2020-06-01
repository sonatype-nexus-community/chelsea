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

require 'chelsea/bom'
require 'chelsea/deps'
require 'ox'
require 'spec_helper'

RSpec.describe Chelsea::Bom do
  before do
     @deps = get_test_dependencies
  end

  it "can render dependencies as xml" do
    bom = Chelsea::Bom.new(@deps)
    expect(bom.xml.class).to eq(Ox::Document)
    expect(bom.to_s.class).to eq(String)
  end
end