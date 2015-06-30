# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'astrid/version'

Gem::Specification.new do |spec|
  spec.name          = "astrid"
  spec.version       = Astrid::VERSION
  spec.authors       = ["JHawk"]
  spec.email         = ["josh.r.hawk@gmail.com"]
  spec.summary       = %q{A Star in ruby.}
  spec.description   = %q{A Star in ruby.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
