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

    def self.to_purl(name, version)
      "pkg:gem/#{name}@#{version}"
    end

    # Parses specs from lockfile instanct var and
    # inserts into dependenices instance var
    def dependencies
      @dependencies ||= lockfile_as_dependencies
      @dependencies
    end

    def reverse_dependencies
      @reverse_dependencies ||= filter_reverse_dependencies
      @reverse_dependencies
    end

    def coordinates
      @coordinates ||= dependencies_as_coordinates
      @coordinates
    end

    # Iterates over all dependencies and stores them
    # in dependencies_versions giand coordinates instance vars
    def dependencies_as_coordinates
      #? Include here? 
      dependencies
        .each_with_object({ 'coordinates' => [] }) do |(name, v), coords|
        coords['coordinates'] << self.class.to_purl(name, v[1])
      end
    end

    # Collects all reverse dependencies in reverse_dependencies instance var
    # this rescue block honks
    def filter_reverse_dependencies
      spec_names = lockfile_spec_names
      reverse_command
        .transform_values! do |reverse_dep|
          reverse_dep.select do |name, _dep, _req, _|
            spec_names.include?(name.split('-')[0])
          end
        end
    end

    private

    def lockfile_spec_names
      @lockfile.specs.map { |i| i.to_s.split }.map do |n, _v|
        n.to_s
      end
    end

    def lockfile_as_dependencies
      @lockfile.specs.each_with_object({}) do |gem, h|
        h[gem.name] = [gem.name, gem.version]
      end
    end

    def reverse_command
      reverse = Gem::Commands::DependencyCommand.new
      reverse.options[:reverse_dependencies] = true
      reverse.options[:pipe_format] = true
      reverse.reverse_dependencies(@lockfile.specs)
    end
  end
end
