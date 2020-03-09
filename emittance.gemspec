# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emittance/version'

Gem::Specification.new do |spec|
  spec.name = 'emittance'
  spec.version = Emittance::VERSION
  spec.authors = ['Tyler Guillen']
  spec.email = ['tyler@tylerguillen.com']

  spec.summary = 'A robust and flexible eventing library for Ruby.'
  spec.description = 'A robust and flexible eventing library for Ruby.'
  spec.homepage = 'https://github.com/aastronautss/emittance'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
