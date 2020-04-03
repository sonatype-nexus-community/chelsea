
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "chelsea/version"

Gem::Specification.new do |spec|
  spec.name          = "chelsea"
  spec.license       = "MIT"
  spec.version       = Chelsea::VERSION
  spec.authors       = ["Allister Beharry"]
  spec.email         = ["allister.beharry@gmail.com"]

  spec.summary       = "Audit Ruby package dependencies for security vulnerabilities."
  spec.homepage      = "https://github.com/sonatype-nexus-community/chelsea"
  
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sonatype-nexus-community/chelsea"
  spec.metadata["changelog_uri"] = "https://github.com/sonatype-nexus-community/chelsea/CHANGELOG"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-font", "~> 0.5.0"
  spec.add_dependency "tty-spinner", "~> 0.9.3"
  spec.add_dependency "slop", "~> 4.8.1"
  spec.add_dependency "pastel", "~> 0.7.2"
  spec.add_dependency "rest-client", "~> 2.0.2"
  spec.add_dependency "bundler", ">= 1.2.0", "< 3"
  spec.add_dependency "ox", "~> 2.13.2"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4.1"
  spec.add_development_dependency "webmock", "~> 3.8.3"
end
