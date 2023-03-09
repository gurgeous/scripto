lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scripto/version"

Gem::Specification.new do |s|
  s.name = "scripto"
  s.version = Scripto::VERSION
  s.authors = ["Adam Doppelt"]
  s.email = ["amd@gurge.com"]

  s.summary = "Helpers for writing command line scripts. An extraction from Dwellable."
  s.homepage = "http://github.com/gurgeous/scripto"
  s.license = "MIT"
  s.required_ruby_version = ">= 3.1.0"

  # what's in the gem?
  s.files = `git ls-files -z`.split("\x0").reject { _1.match(%r{^test/}) }
  s.require_paths = ["lib"]
end
