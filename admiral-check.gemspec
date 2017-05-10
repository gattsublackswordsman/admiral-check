# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'admiral/version'

Gem::Specification.new do |spec|
  spec.name          = 'admiral-check'
  spec.version       = Admiral::ADMIRAL__VERSION
  spec.authors       = ['Gattsu']
  spec.email         = ['gattsu.blackswordsman@gmail.com']
  spec.description   = %q{Deployment and testing tool}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/gattsublackswordsman/admiral-check'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = %w(admiral)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mixlib-shellout', '~> 1.6.1'
  spec.add_runtime_dependency 'net-scp', '~> 1.1'
  spec.add_runtime_dependency 'net-ssh', '~> 2.7'
  spec.add_runtime_dependency 'safe_yaml', '~> 1.0'
  spec.add_runtime_dependency 'thor', '~> 0.18'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
