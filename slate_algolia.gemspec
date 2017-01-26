# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'slate_algolia'
  s.version     = '1.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Joe Wegner']
  s.email       = ['joe@wegnerdesign.com']
  s.summary     = 'Quickly and easily index Slate Docs in Algolia'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  # The version of middleman-core your extension depends on
  s.add_runtime_dependency('middleman-core', ['~> 3.3', '>= 3.3.12'])
  s.add_runtime_dependency('oga', ['~> 1.3', '>= 1.3.1'])
  s.add_runtime_dependency('algoliasearch', ['~> 1.12', '>= 1.12.5'])
end
