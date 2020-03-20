require 'slop'
require 'pastel'
require_relative 'version'

module Chelsea
  class CLI
    def main(command_line_options=ARGV)
      puts show_logo()
      parser = Slop::Parser.new cli_flags()
      arguments = parse_arguments(command_line_options, parser)
      validate_arguments arguments

      if arguments.fetch(:file)
        gems(arguments[:file])
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
      opts.string '-f', '--file', 'do the dang thing'
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

    def gems(file)
      require_relative 'gems'
      Chelsea::Gems.new(file, nil).execute
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
