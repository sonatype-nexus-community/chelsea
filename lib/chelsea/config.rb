require 'yaml'
require_relative 'oss_index'

module Chelsea
  @@oss_index_config_location = File.join("#{Dir.home}", ".ossindex")
  @@oss_index_config_filename = ".oss-index-config"

  def self.config(options={})
    unless options[:user].nil? || options[:token].nil?
      Chelsea::OSSIndex.new(
        oss_index_user_name: options[:user],
        oss_index_user_token: options[:token]
      )
    else
      Chelsea::OSSIndex.new(self.get_oss_index_config)
    end
  end

  def self.client(options={})
    @@oss_index_client ||= config(options)
    @@oss_index_client
  end

  def self.get_oss_index_config
    if !File.exist? File.join(@@oss_index_config_location, @@oss_index_config_filename)
      { :oss_index_user_name => '', :oss_index_user_token => '' }
    else
      conf_hash = YAML.load(File.read(File.join(@@oss_index_config_location, @@oss_index_config_filename)))
      { :oss_index_user_name => conf_hash['Username'], :oss_index_user_token => conf_hash['Token'] }
    end
  end

  def get_white_list_vuln_config(white_list_config_path)
    if white_list_config_path.nil?
      YAML.load(File.read(File.join(Dir.pwd, "chelsea-ignore.yaml")))
    else
      YAML.load(File.read(white_list_config_path))
    end
  end

  def self.get_oss_index_config_from_command_line
    config = {}

    puts "What username do you want to authenticate as (ex: your email address)? "
    config["Username"] = STDIN.gets.chomp

    puts "What token do you want to use? "
    config["Token"] = STDIN.gets.chomp

    self._write_oss_index_config_file(config)
  end

  private

  def self._write_oss_index_config_file(config)
    Dir.mkdir(@oss_index_config_location) unless File.exists? @@oss_index_config_location

    File.open(File.join(@@oss_index_config_location, @@oss_index_config_filename), "w") do |file|
      file.write config.to_yaml
    end
  end

end