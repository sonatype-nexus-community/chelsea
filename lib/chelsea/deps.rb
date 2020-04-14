require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'
require 'json'
require 'rest-client'

require_relative 'dependency_exception'
require_relative 'oss_index'

module Chelsea
  class Deps
    def initialize(path:, quiet: false)
      @quiet = quiet
      ENV['BUNDLE_GEMFILE'] = File.expand_path(path).chomp('.lock')
      begin
        @lockfile = Bundler::LockfileParser.new(File.read(path))
      rescue
        raise "Gemfile.lock not parseable, please check file or that it's path is valid"
      end
    end

    def nil?
      @dependencies.empty?
    end

    def self.to_purl(name, version)
      "pkg:gem/#{name}@#{version}"
    end

    # Parses specs from lockfile instanct var and inserts into dependenices instance var
    def dependencies
      dependencies = {}
      @lockfile.specs.each do |gem|\
        begin
          dependencies[gem.name] = [gem.name, gem.version]
        rescue StandardError => e
          raise Chelsea::DependencyException e, "Parsing dependency line #{gem} failed."
        end
      end
      dependencies
    end

    # Collects all reverse dependencies in reverse_dependencies instance var
    def reverse_dependencies
      reverse_dependencies = {}
      begin
        reverse = Gem::Commands::DependencyCommand.new
        reverse.options[:reverse_dependencies] = true
        reverse_dependencies = reverse.reverse_dependencies(@lockfile.specs).to_h
      rescue => e
        raise Chelsea::DependencyException e, "ReverseDependencyException"
      end
      reverse_dependencies
    end

    # Iterates over all dependencies and stores them
    # in dependencies_versions and coordinates instance vars
    def dependencies_versions_as_coordinates(dependencies)
      dependencies_versions = {}
      coordinates = { 'coordinates' => [] }
      dependencies.each do |p, r|
        v = r[1].to_s
        if v.split('.').length == 1 then
          v = v + ".0.0"
        elsif v.split('.').length == 2 then
            v = v + ".0"
        end
        dependencies_versions[p] = v
      end

      dependencies_versions.each do |p, v|
        coordinates['coordinates'] << self.class.to_purl(p, v);
      end
      coordinates
    end
  end
end
