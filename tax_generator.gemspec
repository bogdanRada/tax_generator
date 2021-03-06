require File.expand_path('../lib/tax_generator/version', __FILE__)
require 'date'
Gem::Specification.new do |s|
  s.name = 'tax_generator'
  s.version = TaxGenerator.gem_version
  s.platform = Gem::Platform::RUBY
  s.description = 'Tax generator is a simple XML processor and generator of HTMl files and uses celluloid to generate files in asyncronous way'
  s.email = 'raoul_ice@yahoo.com'
  s.homepage = 'http://github.com/bogdanRada/tax_generator/'
  s.summary = 'Tax generator is a simple XML processor and generator of HTMl files and generates files asynchronously'
  s.authors = ['bogdanRada']
  s.date = Date.today

  s.licenses = ['MIT']
  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(/^(spec)/)
  s.require_paths = ['lib']
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_runtime_dependency 'nokogiri', '>= 1.7'
  s.add_runtime_dependency 'concurrent-ruby', '>= 1.0'
  s.add_runtime_dependency 'concurrent-ruby-edge', '>= 0.3'
  s.add_runtime_dependency 'slop', '>= 4.4.1'
  s.add_runtime_dependency 'activesupport', '>= 4.1.0'
  s.add_runtime_dependency 'rubytree', '>= 0.9.6'
  s.add_runtime_dependency 'tilt', '>= 2.0.1', '< 3'

  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0'
  s.add_development_dependency 'rspec', '~> 3.9', '>= 3.9'
  s.add_development_dependency 'simplecov', '~> 0.18', '>= 0.18'
  s.add_development_dependency 'simplecov-summary', '~> 0.0.6', '>= 0.0.6'
  s.add_development_dependency 'mocha', '~> 1.11', '>= 1.11'

  s.add_development_dependency 'concurrent-ruby-ext', '~> 1.1' , '>= 1.1'

  s.add_development_dependency 'yard', '~> 0.9', '>= 0.9.20'
  s.add_development_dependency 'redcarpet', '~> 3.5', '>= 3.5'
  s.add_development_dependency 'github-markup', '~> 3.0', '>= 3.0.4'
  s.add_development_dependency 'inch', '~> 0.8', '>= 0.8'
end
