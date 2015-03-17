# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'criterion/version'

Gem::Specification.new do |spec|
  spec.name          = "criterion"
  spec.version       = Criterion::VERSION
  spec.authors       = ["Matthew Solt"]
  spec.email         = ["mattsolt@gmail.com"]

  spec.summary       = %q{Criterion is a small, simple library for searching Ruby arrays and collections with a chainable, Active Record style query interface.}
  spec.description   = %q{Criterion is a small, simple library for searching Ruby arrays and collections with a chainable, Active Record style query interface.}
  spec.homepage      = "https://github.com/activefx/criterion"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "hashie"
end
