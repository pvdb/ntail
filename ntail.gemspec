# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ntail/version'

Gem::Specification.new do |gem|
  gem.name          = "ntail"
  gem.version       = Ntail::VERSION
  gem.authors       = ["Peter Vandenberk"]
  gem.email         = ["pvandenberk@mac.com"]
  gem.description   = %q{A tail(1)-like utility for nginx log files. It supports parsing, filtering and formatting individual log lines.}
  gem.summary       = %q{A tail(1)-like utility for nginx log files.}
  gem.homepage      = "http://github.com/pvdb/ntail"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('methadone', '~> 1.2.2')

  # for building and gem management
  gem.add_development_dependency('rake', '~> 0.9.2')

  # for developing
  gem.add_development_dependency('rdoc')
  gem.add_development_dependency('awesome_print')

  # for debugging
  gem.add_development_dependency('pry-plus')
  gem.add_development_dependency('methodfinder')

  # for testing
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('cucumber')
  gem.add_development_dependency('aruba')

  # for monitoring
  gem.add_development_dependency('guard')
  gem.add_development_dependency('growl')
  gem.add_development_dependency('rb-fsevent')
  gem.add_development_dependency('rb-readline')

  # for TDD/BDD/CI
  gem.add_development_dependency('guard-rspec')
  gem.add_development_dependency('guard-cucumber')
  gem.add_development_dependency('rspec-pride')
  gem.add_development_dependency('cucumber-pride')
end
