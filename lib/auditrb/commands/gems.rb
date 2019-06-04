# frozen_string_literal: true

require 'pastel'
require 'semantic'
#require_relative './version.rb'
require_relative '../command'

module Auditrb
  module Commands
    class Gems < Auditrb::Command
      def initialize(file, options)
        @file = file
        @options = options
        @pastel = Pastel.new
        @dependencies = Hash.new()
        @dependencies_versions = Hash.new()
        @coordinates = Hash.new()
        @coordinates["coordinates"] = Array.new()
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
        get_dependencies_versions()
        get_coordinates()
      end

      def gemspec_file_exists?()
        if not ::File.file? @file
          print_err "Could not fifnd .gemspec file #{@file}."
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
        @dependencies.each do |p, r|
          o =  r[0]
          v = r[1].to_s
          if v.split('.').length == 1 then
            v = v + ".0.0"
          elsif v.split('.').length == 2 then
              v = v + ".0"
          end
          version = Semantic::Version.new(v)
          case o
          when '>'
            version = version.increment!(:minor)
          when '<'
            version = decrement(version)
          end
          #puts "p:#{p} o:#{o} v:#{v} version:#{version}."
          @dependencies_versions[p] = version
        end
        @dependencies_versions.count()
      end

      def get_coordinates()
        @dependencies_versions.each do |p, v|
          @coordinates["coordinates"] <<  "pkg:gem/#{p}@#{v}";
        end
      end

      def decrement(version)
        major = version.major
        minor = version.minor
        patch = version.patch
        if patch > 0 then
          patch = patch - 1
        elsif minor > 0 then
          minor = minor - 1
        elsif major > 0 then
          major = major - 1
        else raise 'Version is 0.0.0'
        end
        Semantic::Version.new("#{major}.#{minor}.#{patch}")
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
