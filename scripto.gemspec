# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scripto/version'

Gem::Specification.new do |spec|
  spec.name          = "scripto"
  spec.version       = Scripto::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 2.0.0"
  spec.authors       = ["Adam Doppelt"]
  spec.email         = ["amd@gurge.com"]
  spec.summary       = "Helpers for writing command line scripts. An extraction from Dwellable."
  spec.homepage      = "http://github.com/gurgeous/scripto"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"
end
