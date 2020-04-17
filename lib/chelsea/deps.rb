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
      @lockfile = Bundler::LockfileParser.new(File.read(path))
    end

    def nil?
      @dependencies.empty?
    end

    def self.to_purl(name, version)
      "pkg:gem/#{name}@#{version}"
    end

    # Parses specs from lockfile instanct var and
    # inserts into dependenices instance var
    def dependencies
      @lockfile.specs.each_with_object({}) do |gem, h|
        h[gem.name] = [gem.name, gem.version]
      end
    end

    # Collects all reverse dependencies in reverse_dependencies instance var
    # this rescue block honks
    def reverse_dependencies
      reverse = Gem::Commands::DependencyCommand.new
      reverse.options[:reverse_dependencies] = true
      # We want to filter the reverses dependencies by specs in lockfile
      spec_names = @lockfile.specs.map { |i| i.to_s.split }.map do |n, _v|
        n.to_s
      end
      reverse
        .reverse_dependencies(@lockfile.specs)
        .to_h
        .transform_values do |reverse_dep|
          reverse_dep.select do |name, _dep, _req, _|
            spec_names.include?(name.split('-')[0])
          end
        end
    end

    # Iterates over all dependencies and stores them
    # in dependencies_versions and coordinates instance vars
    def coordinates
      dependencies.each_with_object({ 'coordinates' => [] }) do |(name, v), coords|
        coords['coordinates'] << self.class.to_purl(name, v[1]);
      end
    end
  end
end
