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

require 'yaml'
require_relative 'oss_index'

# Saved credentials
module Chelsea
  @oss_index_config_location = File.join(Dir.home.to_s, '.ossindex')
  @oss_index_config_filename = '.oss-index-config'

  def self.to_purl(name, version)
    "pkg:gem/#{name}@#{version}"
  end

  def self.config(options = {})
    if !options[:user].nil? && !options[:token].nil?
      Chelsea::OSSIndex.new(
        options: {
          oss_index_user_name: options[:user],
          oss_index_user_token: options[:token],
          oss_index_url: options[:ossindex_url]
        }
      )
    else
      config_opts = oss_index_config
      config_opts[:oss_index_url] = options[:ossindex_url] unless options[:ossindex_url].nil?
      Chelsea::OSSIndex.new(options: config_opts)
    end
  end

  def self.client(options = {})
    @client ||= config(options)
    @client
  end

  def self.oss_index_config # rubocop:disable Metrics/MethodLength
    if File.exist? File.join(@oss_index_config_location, @oss_index_config_filename)
      conf_hash = YAML.safe_load(
        File.read(
          File.join(@oss_index_config_location, @oss_index_config_filename)
        )
      )
      {
        oss_index_user_name: conf_hash['Username'],
        oss_index_user_token: conf_hash['Token'],
        oss_index_url: conf_hash['OSSIndexUrl'] || 'https://ossindex.sonatype.org'
      }
    else
      { oss_index_user_name: '', oss_index_user_token: '', oss_index_url: 'https://ossindex.sonatype.org' }
    end
  end

  def get_white_list_vuln_config(white_list_config_path)
    if white_list_config_path.nil?
      YAML.safe_load(File.read(File.join(Dir.pwd, 'chelsea-ignore.yaml')))
    else
      YAML.safe_load(File.read(white_list_config_path))
    end
  end

  def self.read_oss_index_config_from_command_line
    config = {}

    puts 'What username do you want to authenticate as (ex: your email address)? '
    config['Username'] = $stdin.gets.chomp

    puts 'What token do you want to use? '
    config['Token'] = $stdin.gets.chomp

    puts 'What OSS Index URL do you want to use? (default: https://ossindex.sonatype.org) '
    url_input = $stdin.gets.chomp
    config['OSSIndexUrl'] = url_input.empty? ? 'https://ossindex.sonatype.org' : url_input

    _write_oss_index_config_file(config)
  end

  def self._write_oss_index_config_file(config)
    Dir.mkdir(@oss_index_config_location) unless File.exist? @oss_index_config_location
    File.open(File.join(@oss_index_config_location, @oss_index_config_filename), 'w') do |file|
      file.write config.to_yaml
    end
  end
end
