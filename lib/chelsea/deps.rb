require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'
require_relative 'dependency_exception'

module Chelsea
  class Deps
    # read lock file from disk
    def initialize(path: , quiet: false)
      @path, @quiet = path, quiet

      begin
        @lockfile = Bundler::LockfileParser.new(
          File.read(@path)
        )
      rescue
        raise "Gemfile.lock not parseable, please check file or that it's path is valid"
      end

      @dependencies = Hash.new
      _get_dependencies

      @reverse_dependencies = Hash.new
      begin
        @reverse_dependencies  = _get_reverse_dependencies
      rescue Chelsea::DependencyException => e
        if !@quiet
          raise Chelsea::DependencyException "Reverse Dependency...failed."
        end
      end

    end

    def to_h(reverse: false)
      if reverse
        @reverse_dependencies.to_h
      else
        @dependencies.to_h
      end
    end

    def to_coordinates
      return _get_dependencies_versions_as_coordinates
    end

    def self.to_purl(name, version)
      return "pkg:gem/#{name}@#{version}"
    end

    protected

    def _get_dependencies
      @lockfile.specs.each do |gem|\
        begin
          @dependencies[gem.name] = [gem.name, gem.version]
        rescue StandardError => e
          raise Chelsea::DependencyException e, "Parsing dependency line #{gem} failed."
        end
        raise "Parsing dependency line #{gem} failed."

        @dependencies
      rescue => e

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

    def _get_dependencies_versions_as_coordinates

      dependencies_versions = Hash.new()

      @dependencies.to_h.each do |p, r|
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
        coordinates["coordinates"] << self.class.to_purl(p,v)
      end
      coordinates
    end
  end
end
