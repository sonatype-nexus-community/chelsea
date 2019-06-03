# frozen_string_literal: true

require 'pastel'
require 'semantic'
require_relative '../command'

module Auditrb
  module Commands
    class Gems < Auditrb::Command
      def initialize(file, options)
        @file = file
        @options = options
        @pastel = Pastel.new
        @dependencies = Hash.new()
        @versions
      end

      def execute(input: $stdin, output: $stdout)
        if not gemspec_file_exists?
          return
        end
        n = get_dependencies()
        puts "Parsed #{n} dependencies."
        if n == 0
          print_err "No dependencies retrieved. Exiting."
          return
        end
      end

      def gemspec_file_exists?()
        if not ::File.file? @file
          print_err "Could not find .gemspec file #{@file}."
          return false
        else
          require 'pathname'
          path = Pathname.new(@file)  
          print_success "Using .gemspec file #{path.realpath}."
          return true
        end
      end

      def get_dependencies()
        IO.foreach(@file) do |x|
          case x
          when /^\s*spec\.add_dependency\s+"?([^"]+)"?,\s*(.+)$/
            p = $1
            v = $2.to_s
            r = 
              if v.start_with?('"') then 
                v.gsub!(/\A"|"\Z/, '') 
              else 
                v 
              end 
            @dependencies[p] = Gem::Requirement.parse(r)
          end
        end
        @dependencies.count()
      end

      def get_dependencies_versions()
        @dependencies.each do |p, v|
          v
          #spec = v.to_spec()
          #version = Gem::Version.new(v.)
          rescue Gem::MissingSpecError => error
            print_err "Parsing dependency #{p} failed: #{error}."       
        end
      end

      def print_err(s)
        puts @pastel.red.bold(s)
      end

      def print_success(s)
        puts @pastel.green.bold(s)
      end

    end
  end
end
