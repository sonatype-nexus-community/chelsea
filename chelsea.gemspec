# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chelsea/version'

Gem::Specification.new do |spec|
  spec.name          = 'chelsea'
  spec.license       = 'Apache-2.0'
  spec.version       = Chelsea::VERSION
  spec.authors       = ['Allister Beharry']
  spec.email         = ['allister.beharry@gmail.com']
  spec.required_ruby_version = '>= 2.6.6'

  spec.summary       = 'Audit Ruby package dependencies for security vulnerabilities.'
  spec.homepage      = 'https://github.com/sonatype-nexus-community/chelsea'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/sonatype-nexus-community/chelsea'
  spec.metadata['changelog_uri'] = 'https://github.com/sonatype-nexus-community/chelsea/CHANGELOG'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bundler', '>= 1.2.0', '< 3'
  spec.add_dependency 'ox', '~> 2.13.2'
  spec.add_dependency 'pastel', '~> 0.7.2'
  spec.add_dependency 'rest-client', '~> 2.0.2'
  spec.add_dependency 'slop', '~> 4.8.1'
  spec.add_dependency 'tty-font', '~> 0.5.0'
  spec.add_dependency 'tty-spinner', '~> 0.9.3'
  spec.add_dependency 'tty-table', '~> 0.11.0'

  spec.add_development_dependency 'byebug', '~> 11.1.2'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  spec.add_development_dependency 'webmock', '~> 3.8.3'
end
