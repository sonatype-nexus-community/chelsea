#
# Copyright 2019-Present Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'bundler'
require 'bundler/lockfile_parser'
require 'rubygems'
require 'rubygems/commands/dependency_command'
require 'json'
require 'rest-client'

module Chelsea
  # Reads a lockfile for dependencies
  class Deps
    attr_reader :dependencies
    def initialize(path:, verbose: false)
      @verbose = verbose
      ENV['BUNDLE_GEMFILE'] = File.expand_path(path).chomp('.lock')
      @lockfile = Bundler::LockfileParser.new(File.read(path))
      # Generates hash from lockfile specs
      @dependencies = @lockfile.specs.each_with_object({}) do |gem, h|
        h[gem.name] = [gem.name, gem.version]
      end
    end

    def nil?
      @dependencies.empty?
    end

    def self.to_purl(name, version)
      "pkg:gem/#{name}@#{version}"
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
        .transform_values! do |reverse_dep|
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
