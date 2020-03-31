require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'
require_relative 'dependency_exception'

module Chelsea
  class Deps
    # read lock file from disk
    def initialize(options)
      begin
        @lockfile = Bundler::LockfileParser.new(
          File.read(options[:path])
        )
      rescue
        raise "Gemfile.lock not parseable, please check file or that it's path is valid"
      end
      @dependencies = Hash.new()
      @reverse_dependencies  = Hash.new()
    end

    def to_h(reverse: false)
      if reverse
        if @dependencies.count == 0
          _get_dependencies
        end
        @dependencies
      else
        if @reverse_dependencies.count == 0
          _get_reverse_dependencies
        end
        @reverse_dependencies
      end
    end

    def self.to_coordinates(dep_hash)
      return self._get_dependencies_versions_as_coordinates(dep_hash)
    end

    def self.to_purl(name, version)
      return "pkg:gem/#{name}@#{version}"
    end

    protected

    def _get_dependencies
      begin
        @lockfile.specs.each do |gem|
          @dependencies[gem.name] = [gem.name, gem.version]
        end
        @dependencies
      rescue => e
        raise Chelsea::DependencyException e, "LockFileParseException"
      end
    end

    def _get_reverse_dependencies
      begin
        reverse = Gem::Commands::DependencyCommand.new
        reverse.options[:reverse_dependencies] = true
        @reverse_dependencies = reverse.reverse_dependencies(@lockfile.specs).to_h
      rescue => e
        raise Chelsea::DependencyException e, "ReverseDependencyException"
      end
    end

    def self._get_dependencies_versions_as_coordinates(dependencies)

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
        coordinates["coordinates"] << self.to_purl(p, v)
      end


      coordinates
    end
  end
end
