# frozen_string_literal: true

require 'pastel'
require_relative '../command'

module Auditrb
  module Commands
    class Gems < Auditrb::Command
      def initialize(file, options)
        @file = file
        @options = options
        @pastel = Pastel.new

      end

      def execute(input: $stdin, output: $stdout)
        show_logo()
        if not gemspec_file_exists?
          return
        end
      end

      def show_logo()
        require 'tty-font'
        font = TTY::Font.new(:doom)
        $stdout.puts @pastel.green(font.write("auditrb"))
      end

      def gemspec_file_exists?()
        if not ::File.file? @file
          print_err "Could not find .gemspec file #{@file}."
          return false
        else
          require 'pathname'
          path = Pathname.new(@file)  
          print_ok "Using .gemspec file #{path.realpath}."
          return true
        end
      end

      def print_err(s)
        $stdout.puts @pastel.red.bold(s)
      end

      def print_ok(s)
        $stdout.puts @pastel.green.bold(s)
      end



    end
  end
end
