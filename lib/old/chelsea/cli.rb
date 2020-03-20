# frozen_string_literal: true

require 'thor'

module Chelsea
  # # Handle the application command line parsing
  # # and the dispatch to various command objects
  # #
  # # @api public
  # class CLI < Thor
  #   # Error raised by this runner
  #   Error = Class.new(StandardError)

  #   desc 'version', 'chelsea version'
  #   def version
  #     require_relative 'version'
  #     puts "v#{Chelsea::VERSION}"
  #   end
  #   map %w(--version -v) => :version

  #   desc 'gems FILE', 'Audit dependencies specified in a .gemspec file.'
  #   method_option :help, aliases: '-h', type: :boolean,
  #                        desc: 'Display usage information'
  #   def gems(file)
  #     if options[:help]
  #       invoke :help, ['gems']
  #     else
  #       require_relative 'commands/gems'
  #       Chelsea::Commands::Gems.new(file, options).execute
  #     end
  #   end
  # end
end
