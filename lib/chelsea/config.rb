require 'yaml'

module Chelsea
  class Config
    def initialize(opts = {})
      @@oss_index_config_location = File.join("#{Dir.home}", ".ossindex")
      @@oss_index_config_filename = ".oss-index-config"
    end

    def get_oss_index_config()
      oss_index_config = YAML.load(File.read(File.join(@@oss_index_config_location, @@oss_index_config_filename)))

      oss_index_config
    end

    def self.get_white_list_vuln_config(white_list_config_path)
      if white_list_config_path.nil?
        white_list_vuln_config = YAML.load(File.read(File.join(Dir.pwd, "chelsea-ignore.yaml")))
      else
        white_list_vuln_config = YAML.load(File.read(white_list_config_path))
      end

      white_list_vuln_config
    end

    def get_oss_index_config_from_command_line()
      config = {}

      puts "What username do you want to authenticate as (ex: your email address)?"
      config["Username"] = gets
      config["Username"] = config["Username"].chomp

      puts "What token do you want to use?"
      config["Token"] = gets
      config["Token"] = config["Token"].chomp

      _set_oss_index_config(config)
    end

    private

      def _set_oss_index_config(config)
        Dir.mkdir(@@oss_index_config_location) unless File.exists? @@oss_index_config_location

        File.open(File.join(@@oss_index_config_location, @@oss_index_config_filename), "w") do |file|
          file.write config.to_yaml
        end
      end

  end
end
