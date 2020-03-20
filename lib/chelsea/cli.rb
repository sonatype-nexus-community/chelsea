require 'slop'
require 'pastel'
require_relative './version'

module Chelsea
  class CLI
    def main(command_line_options=ARGV)
      puts show_logo()
      parser = Slop::Parser.new cli_flags()
      arguments = parse_arguments(command_line_options, parser)
    end

    def cli_flags()
      opts = Slop::Options.new
      opts.banner = "usage: chelsea [options] ..."
      opts.separator ""
      opts.on '--version', 'print the version' do
        puts version()
        exit
      end

      opts
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
