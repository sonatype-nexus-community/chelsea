require 'slop'
require 'pastel'
require_relative 'version'

module Chelsea
  class CLI
    def main(command_line_options=ARGV)
      parser = Slop::Parser.new cli_flags()
      arguments = parse_arguments(command_line_options, parser)
      validate_arguments arguments

      if !arguments.fetch(:quiet) && arguments.fetch(:format) == 'text'
        puts show_logo()
      end

      if arguments.fetch(:file)
        quiet = (arguments[:quiet] || !(arguments.fetch(:format) == 'text'))
        gems(arguments[:file], {quiet: quiet, format: arguments[:format]})
      elsif set?(arguments, :help)
        puts cli_flags
      end
    end

    def set?(arguments, flag)
      !arguments.fetch(flag).nil?
    end

    def cli_flags()
      opts = Slop::Options.new
      opts.banner = "usage: chelsea [options] ..."
      opts.separator ""
      opts.separator 'Options:'
      opts.bool '-h', '--help', 'show usage'
      opts.bool '-q', '--quiet', 'make chelsea only output vulnerable third party dependencies for text output (default: false)', default: false 
      opts.string '-t', '--format', 'choose what type of format you want your report in (default: text) (options: text, json, xml)', default: 'text'
      opts.string '-f', '--file', 'path to your Gemfile.lock'
      opts.on '--version', 'print the version' do
        puts version()
        exit
      end

      opts
    end

    def validate_arguments(arguments)
      if number_of_required_flags_set(arguments) < 1 && !arguments.fetch(:file)
        flags_error
      end
    end

    def number_of_required_flags_set(arguments)
      minimum_flags = flags
      valid_flags = minimum_flags.collect {|a| arguments.fetch(a) }.compact
      valid_flags.count
    end

    def flags
      [:file, :help]
    end

    def flags_error
      switches = flags.collect {|f| "--#{f}"}
      puts cli_flags
      puts
      abort "please set one of #{switches}"
    end

    def gems(file, options)
      require_relative 'gems'
      Chelsea::Gems.new(file, options).execute
    end

    def parse_arguments(command_line_options, parser)
      begin
        result = parser.parse command_line_options
        result.to_hash

      rescue Slop::UnknownOption
        # print help
        puts cli_flags()
        exit
      end
    end

    def version()
      Chelsea::VERSION
    end
  
    def show_logo()
      @pastel = Pastel.new
      require 'tty-font'
      font = TTY::Font.new(:doom)
      puts @pastel.green(font.write("Chelsea"))
      puts @pastel.green("Version: " + version())
    end
  end
end
