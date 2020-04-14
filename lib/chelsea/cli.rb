require 'slop'
require 'pastel'
require 'tty-font'

require_relative 'version'
require_relative 'gems'
require_relative 'iq_client'
require_relative 'config'

module Chelsea
  ##
  # This class provides an interface to the oss index, gems and deps
  class CLI

    def initialize(opts)
      @opts = opts
      @pastel = Pastel.new
      _validate_arguments
      _show_logo # Move to formatter
    end

    def process!
      if @opts.config?
        _set_config # move to init
      end
      if @opts.file? # don't process unless there was a file
        @gems = Chelsea::Gems.new(file: @opts[:file], quiet: @opts[:quiet], options: @opts)
        @gems.execute # should be more like collect
        if @opts.sbom?
          @iq = Chelsea::IQClient.new(@opts[:application], @opts[:server], @opts[:iquser], @opts[:iqpass])
          bom = Chelsea::Bom.new(@gems.deps)
          @iq.submit_sbom(bom)
        end
      elsif @opts.help? # quit on opts.help earlier
        puts _cli_flags # this doesn't exist
      end
    end

    # this is how you do static methods in ruby, because in a test we want to 

    # check for version without opts, and heck, we don't even want a dang object!
    def self.version
      Chelsea::VERSION
    end

  protected

    def _flags_error
      # should be custom exception! 
      switches = _flags.collect {|f| "--#{f}"}

      abort "please set one of #{switches}"
    end

    def _validate_arguments
      if !_flags_set? && !@opts.file?
        ## require at least one argument
        _flags_error
      end
    end

    def _flags_set?
      # I'm still unsure what this is trying to express
      valid_flags = _flags.collect {|arg| @opts[arg] }.compact
      valid_flags.count > 1
    end

    def _flags
      # Seems wrong, should all be handled by bin
      %i[file help config]
    end

    def _show_logo
      font = TTY::Font.new(:doom)
      puts @pastel.green(font.write('Chelsea'))
      puts @pastel.green('Version: ' + CLI.version)
    end

    def _load_config
      config = Chelsea::Config.new
      config.get_oss_index_config()
    end

    def _set_config
      Chelsea.get_oss_index_config_from_command_line
    end
  end
end
