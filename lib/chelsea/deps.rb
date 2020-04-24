require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'
require 'json'
require 'rest-client'

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
      _reverse_command
        .transform_values! do |reverse_dep|
          reverse_dep.select do |name, _dep, _req, _|
            _lockfile_specs.include?(name.split('-')[0])
          end
        end
    end

    # Iterates over all dependencies and stores them
    # in dependencies_versions and coordinates instance vars
    def coordinates
      dependencies
        .each_with_object({ 'coordinates' => [] }) do |(name, v), coords|
        coords['coordinates'] << self.class.to_purl(name, v[1])
      end
    end

    def _reverse_command
      reverse = Gem::Commands::DependencyCommand.new
      reverse.options[:reverse_dependencies] = true
      reverse.options[:pipe_format] = true
      reverse.reverse_dependencies(@lockfile.specs)
    end

    def _lockfile_specs
      @spec_names ||= @lockfile.specs.map { |i| i.to_s.split }.map do |n, _v|
        n.to_s
      end
      @spec_names
    end
  end
end
