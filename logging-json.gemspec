# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logging/plugins/version'

Gem::Specification.new do |spec|
  spec.name          = 'logging-json'
  spec.version       = Logging::Plugins::Json.version
  spec.authors       = ['Michał Knapik']
  spec.email         = %w(michal.knapik@u2i.com)

  spec.summary       = 'JSON formatter for `logging` gem'
  spec.description   = 'Allows to pass objects as messages and format them as JSON'
  spec.homepage      = 'https://github.com/mknapik/logging-json'

  spec.required_ruby_version = '>= 2.3'

  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.add_dependency 'logging', '~> 2.1.0'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'rubocop', '~> 0.43.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.7.0'
end
