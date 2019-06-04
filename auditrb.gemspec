
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "auditrb/version"

Gem::Specification.new do |spec|
  spec.name          = "auditrb"
  spec.license       = "MIT"
  spec.version       = Auditrb::VERSION
  spec.authors       = ["Allister Beharry"]
  spec.email         = ["allister.beharry@gmail.com"]

  spec.summary       = "Audit Ruby package dependencies for security vulnerabilities."
  spec.homepage      = "https://github.com/allisterb/auditrb"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/allisterb/auditrb"
    spec.metadata["changelog_uri"] = "https://github.com/allisterb/auditrb/CHANGELOG"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-box", "~> 0.3.0"
  spec.add_dependency "tty-color", "~> 0.4"
  spec.add_dependency "tty-command", "~> 0.8.0"
  spec.add_dependency "tty-config", "~> 0.3.0"
  spec.add_dependency "tty-cursor", "~> 0.6"
  spec.add_dependency "tty-editor", "~> 0.5.0"
  spec.add_dependency "tty-file", "~> 0.7.0"
  spec.add_dependency "tty-font", "~> 0.2.0"
  spec.add_dependency "tty-markdown", "~> 0.5.0"
  spec.add_dependency "tty-pager", "~> 0.12.0"
  spec.add_dependency "tty-pie", "~> 0.1.0"
  spec.add_dependency "tty-platform", "~> 0.2.0"
  spec.add_dependency "tty-progressbar", "~> 0.16.0"
  spec.add_dependency "tty-prompt", "~> 0.18.0"
  spec.add_dependency "tty-screen", "~> 0.6"
  spec.add_dependency "tty-spinner", "~> 0.9.0"
  spec.add_dependency "tty-table", "~> 0.10.0"
  spec.add_dependency "tty-tree", "~> 0.2.0"
  spec.add_dependency "tty-which", "~> 0.4"
  spec.add_dependency "pastel", "~> 0.7.2"
  spec.add_dependency "thor", "~> 0.20.0"
  spec.add_dependency "semantic" "~> 1.6.1"
  spec.add_dependency "foo", "< 2.2.0"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "tty", "~> 0.9"
end
