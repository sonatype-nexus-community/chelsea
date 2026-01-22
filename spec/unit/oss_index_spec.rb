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
    it 'should use default OSS Index URL' do
      expect(@oss.send(:_api_url)).to eq 'https://ossindex.sonatype.org/api/v3/component-report'
    end
  end

  context 'with custom OSS Index URL' do
    before(:all) do
      @custom_url = 'https://custom.ossindex.example.com'
      @oss = Chelsea::OSSIndex.new(
        options: {
          oss_index_user_name: '',
          oss_index_user_token: '',
          oss_index_url: @custom_url
        }
      )
    end

    it 'should use custom OSS Index URL' do
      expect(@oss.send(:_api_url)).to eq "#{@custom_url}/api/v3/component-report"
    end

    it 'should make request to custom URL' do
      coordinates = { 'coordinates' => ['pkg:gem/test@1.0.0'] }
      stub_request(:post, "#{@custom_url}/api/v3/component-report")
        .to_return(status: 200, body: '[]', headers: { 'Content-Type' => 'application/json' })

      @oss.call_oss_index(coordinates)

      expect(
        a_request(:post, "#{@custom_url}/api/v3/component-report")
      ).to have_been_made.once
    end
  end

  context 'with custom OSS Index URL and credentials' do
    before(:all) do
      @custom_url = 'https://secure.ossindex.example.com'
      @username = 'test@example.com'
      @token = 'test-token-123'
      @oss = Chelsea::OSSIndex.new(
        options: {
          oss_index_user_name: @username,
          oss_index_user_token: @token,
          oss_index_url: @custom_url
        }
      )
    end

    it 'should use custom OSS Index URL with authentication' do
      expect(@oss.send(:_api_url)).to eq "#{@custom_url}/api/v3/component-report"
    end

    it 'should make authenticated request to custom URL' do
      coordinates = { 'coordinates' => ['pkg:gem/test@1.0.0'] }
      stub_request(:post, "#{@custom_url}/api/v3/component-report")
        .with(basic_auth: [@username, @token])
        .to_return(status: 200, body: '[]', headers: { 'Content-Type' => 'application/json' })

      @oss.call_oss_index(coordinates)

      expect(
        a_request(:post, "#{@custom_url}/api/v3/component-report")
          .with(basic_auth: [@username, @token])
      ).to have_been_made.once
    end
  end

  context 'with nil OSS Index URL (should fallback to default)' do
    before(:all) do
      @oss = Chelsea::OSSIndex.new(
        options: {
          oss_index_user_name: '',
          oss_index_user_token: '',
          oss_index_url: nil
        }
      )
    end

    it 'should fallback to default OSS Index URL' do
      expect(@oss.send(:_api_url)).to eq 'https://ossindex.sonatype.org/api/v3/component-report'
    end
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
