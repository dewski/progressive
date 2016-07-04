# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'progressive/version'

Gem::Specification.new do |spec|
  spec.name          = 'progressive'
  spec.version       = Progressive::VERSION
  spec.authors       = ['dewski']
  spec.email         = ['me@garrettbjerkhoel.com']
  spec.description   = 'A lightweight ActiveModel backed state machine.'
  spec.summary       = 'A lightweight ActiveModel backed state machine.'
  spec.homepage      = 'https://github.com/dewski/progressive'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '>= 5.0.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
