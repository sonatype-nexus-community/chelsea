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
        deps = get_test_dependencies
        bom = Chelsea::Bom.new(deps)
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
        auth_token: 'iqpass',
        stage: 'iqstage'
      }
      @client = Chelsea::IQClient.new(options: @opts)
    }
    it 'should be able to submit an sbom' do
      deps = get_test_dependencies
      bom = Chelsea::Bom.new(deps)
      stub_iq_response(**@opts)
      stub_sbom(**@opts)
      expect(@client.post_sbom(bom)).to eq "api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/status/9cee2b6366fc4d328edc318eae46b2cb"
    end
  end
  context 'with report response' do
    status_url = "api/v2/scan/applications/4537e6fe68c24dd5ac83efd97d4fc2f4/status/9cee2b6366fc4d328edc318eae46b2cb"
    absolute_report_url_message = "Report URL: http://localhost:8070/ui/links/application/test-app/report/95c4c14e"
    before(:all) {
      @client = Chelsea::IQClient.new
    }
    it 'should handle policyAction:UnknownAction with relative report url' do
      stub_iq_poll_response(policyAction: "SomeNewPolicyAction")
      msg, color, exit_code = @client.poll_status(status_url)
      expect(msg.include? absolute_report_url_message).to be true
      expect(color).to eq Chelsea::IQClient::COLOR_FAILURE
      expect(exit_code).to eq 1
    end
    it 'should handle policyAction:None with relative report url' do
      stub_iq_poll_response
      msg, color, exit_code = @client.poll_status(status_url)
      expect(msg.include? absolute_report_url_message).to be true
      expect(color).to eq Chelsea::IQClient::COLOR_NONE
      expect(exit_code).to eq 0
    end
    it 'should handle policyAction:Warning with relative report url' do
      stub_iq_poll_response(policyAction: "Warning")
      msg, color, exit_code = @client.poll_status(status_url)
      expect(msg.include? absolute_report_url_message).to be true
      expect(color).to eq Chelsea::IQClient::COLOR_WARNING
      expect(exit_code).to eq 0
    end
    it 'should handle policyAction:Failure with relative report url' do
      stub_iq_poll_response(policyAction: "Failure")
      msg, color, exit_code = @client.poll_status(status_url)
      expect(msg.include? absolute_report_url_message).to be true
      expect(color).to eq Chelsea::IQClient::COLOR_FAILURE
      expect(exit_code).to eq 1
    end
    old_report_url = "http://myAbsoluteReportURL"
    old_report_url_message = "Report URL: #{old_report_url}"
    it 'should handle policyAction:None with absolute report url' do
      stub_iq_poll_response(reportHtmlUrl: old_report_url)
      msg, color, exit_code = @client.poll_status(status_url)
      expect(msg.include? old_report_url_message).to be true
      expect(color).to eq Chelsea::IQClient::COLOR_NONE
      expect(exit_code).to eq 0
    end
    it 'should handle policyAction:Warning with absolute report url' do
      stub_iq_poll_response(policyAction: "Warning", reportHtmlUrl: old_report_url)
      msg, color, exit_code = @client.poll_status(status_url)
      expect(msg.include? old_report_url_message).to be true
      expect(color).to eq Chelsea::IQClient::COLOR_WARNING
      expect(exit_code).to eq 0
    end
    it 'should handle policyAction:Failure with absolute report url' do
      stub_iq_poll_response(policyAction: "Failure", reportHtmlUrl: old_report_url)
      msg, color, exit_code = @client.poll_status(status_url)
      expect(msg.include? old_report_url_message).to be true
      expect(color).to eq Chelsea::IQClient::COLOR_FAILURE
      expect(exit_code).to eq 1
    end
  end
end
