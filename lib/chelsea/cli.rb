require 'slop'
require 'pastel'
require_relative 'version'
require_relative 'gems'

module Chelsea
  ##
  # This class provides an interface to the oss index, gems and deps
  class CLI

    def initialize(opts)
      @opts = opts
      _validate
      _show_logo
    end

    def process!
      if opts.file?
        @gems = Chelsea::Gems.new(opts[:file])
        @gems.execute
      elsif opts.help?
        puts _cli_flags
      end
    end

    def self.version
      Chelsea::VERSION
    end

  protected

    def _cli_flags
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

    def _flags_error
      # should be custom exception! 
      switches = flags.collect {|f| "--#{f}"}
      puts cli_flags
      puts
      abort "please set one of #{switches}"
    end

    def _validate(arguments)
      if _number_of_required_flags_set(arguments) < 1 && !arguments[:file]
        ## require at least one argument
        _flags_error
      end
    end

    def _number_of_required_flags_set(arguments)
      # I'm still unsure what this is trying to express
      valid_flags = flags.collect {|arg| arguments[arg] }.compact
      valid_flags.count
    end

    def _flags
      # Seems wrong, should all be handled by bin
      [:file, :help]
    end

    def _show_logo()
      @pastel = Pastel.new
      require 'tty-font'
      font = TTY::Font.new(:doom)
      puts @pastel.green(font.write("Chelsea"))
      puts @pastel.green("Version: " + version())
    end
  end
end
