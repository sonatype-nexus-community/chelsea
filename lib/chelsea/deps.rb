require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'
require_relative 'dependency_exception'

module Chelsea
  class Deps
    def initialize(options)
      @lockfile = Bundler::LockfileParser.new(
        File.read(options[:path])
      )
    end

    def get_dependencies()
      dependencies = Hash.new()
      
      begin
        @lockfile.specs.each do |gem|
          dependencies[gem.name] = [gem.name, gem.version]
        end
      rescue => e
        raise Chelsea::DependencyException e, "LockFileParseException"
      end

      return dependencies
    end

    def get_reverse_dependencies()
      begin
        reverse = Gem::Commands::DependencyCommand.new
        reverse.options[:reverse_dependencies] = true
        reverse_deps = reverse.reverse_dependencies(@lockfile.specs)
      rescue => e
        raise Chelsea::DependencyException e, "ReverseDependencyException"
      end
    end

    def get_dependencies_versions_as_coordinates(dependencies)
      dependencies_versions = Hash.new()

      dependencies.each do |p, r|
        o =  r[0]
        v = r[1].to_s
        if v.split('.').length == 1 then
          v = v + ".0.0"
        elsif v.split('.').length == 2 then
            v = v + ".0"
        end
        dependencies_versions[p] = v
      end

      coordinates = Hash.new()
      coordinates["coordinates"] = Array.new()

      dependencies_versions.each do |p, v|
        coordinates["coordinates"] << to_purl(p, v)
      end

      return coordinates
    end

    def to_purl(name, version)
      return "pkg:gem/#{name}@#{version}"
    end
  end
end
