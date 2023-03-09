lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scripto/version"

Gem::Specification.new do |spec|
  spec.name = "scripto"
  spec.version = Scripto::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 3.1.0"
  spec.authors = ["Adam Doppelt"]
  spec.email = ["amd@gurge.com"]
  spec.summary = "Helpers for writing command line scripts. An extraction from Dwellable."
  spec.homepage = "http://github.com/gurgeous/scripto"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { File.basename(_1) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "ruby-lsp"
  spec.add_development_dependency "standard"
end
