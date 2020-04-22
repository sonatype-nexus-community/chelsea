require 'yaml'
require_relative 'oss_index'

module Chelsea
  @oss_index_config_location = File.join(Dir.home.to_s, '.ossindex')
  @oss_index_config_filename = '.oss-index-config'
  @iq_config_location = File.join(Dir.home.to_s, '.iqserver')
  @iq_config_filename = '.iq-server-config'

  def self.to_purl(name, version)
    "pkg:gem/#{name}@#{version}"
  end

  def self.config(options = {})
    if !options[:user].nil? && !options[:token].nil?
      Chelsea::OSSIndex.new(
        options: {
          oss_index_user_name: options[:user],
          oss_index_user_token: options[:token]
        }
      )
    else
      Chelsea::OSSIndex.new(options: oss_index_config)
    end
  end

  def self.client(options = {})
    @client ||= config(options)
    @client
  end

  def self.oss_index_config
    if !File.exist? File.join(@oss_index_config_location, @oss_index_config_filename)
      { oss_index_user_name: '', oss_index_user_token: '' }
    else
      conf_hash = YAML.safe_load(
        File.read(
          File.join(@oss_index_config_location, @oss_index_config_filename)
        )
      )
      {
        oss_index_user_name: conf_hash['Username'],
        oss_index_user_token: conf_hash['Token']
      }
    end
  end

  def self.iq_config
    if !File.exist? File.join(@iq_config_location, @iq_config_filename)
      { iq_user_name: '', iq_token: '', iq_server_address: '' }
    else
      conf_hash = YAML.safe_load(
        File.read(
          File.join(@iq_config_location, @iq_config_filename)
        )
      )
      {
        iq_user_name: conf_hash['Username'],
        iq_token: conf_hash['Token'],
        iq_server_address: conf_hash['Server']
      }
    end
  end

  def get_white_list_vuln_config(white_list_config_path)
    if white_list_config_path.nil?
      YAML.safe_load(File.read(File.join(Dir.pwd, 'chelsea-ignore.yaml')))
    else
      YAML.safe_load(File.read(white_list_config_path))
    end
  end

  def self.read_config_from_command_line
    config = {}

    puts 'Hi! What config can I help you set, IQ or OSS Index (values: iq, ossindex, enter for exit)? '
    type = STDIN.gets.chomp

    case type
    when 'iq'
      self._read_iq_config_from_command_line()
    when 'ossindex'
      self._read_oss_index_config_from_command_line()
    when ''
      exit 0
    else
      puts "Invalid value: #{type}, please try again."
      read_config_from_command_line
    end
  end

  private

  def self._write_config_file(config, location, filename)
    unless File.exist? location
      Dir.mkdir(location)
    end
    File.open(File.join(location, filename), "w") do |file|
      file.write config.to_yaml
    end
  end 

  def self._read_oss_index_config_from_command_line
    puts 'What username do you want to authenticate as (ex: your email address)? '
    config['Username'] = STDIN.gets.chomp

    puts 'What token do you want to use? '
    config['Token'] = STDIN.gets.chomp

    _write_config_file(config, @oss_index_config_location, @oss_index_config_filename)
  end

  def self._read_iq_config_from_command_line
    config = {}

    puts 'What username do you want to authenticate as (ex: admin)? '
    config['Username'] = STDIN.gets.chomp

    puts 'What token do you want to use? '
    config['Token'] = STDIN.gets.chomp

    puts 'What server address do you want to use (ex: http://localhost:8070)? '
    config['Server'] = STDIN.gets.chomp

    _write_config_file(config, @iq_config_location, @iq_config_filename)
  end
end