# frozen_string_literal: true

require 'thor'

module Auditrb
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'auditrb version'
    def version
      require_relative 'version'
      puts "v#{Auditrb::VERSION}"
    end
    map %w(--version -v) => :version
  end
end
