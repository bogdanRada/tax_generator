require File.expand_path('../lib/tax_generator/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'tax_generator'
  s.version = TaxGenerator.gem_version
  s.platform = Gem::Platform::RUBY
  s.description = 'Tax generator is a simple XML processor and generator of HTMl files'
  s.email = 'raoul_ice@yahoo.com'
  s.homepage = 'http://github.com/bogdanRada/tax_generator/'
  s.summary = 'Tax generator is a simple XML processor and generator of HTMl files'
  s.authors = ['bogdanRada']
  s.date = Date.today

  s.licenses = ['MIT']
  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(/^(spec)/)
  s.require_paths = ['lib']
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.7'
  s.add_runtime_dependency 'celluloid', '~> 0.16', '~> 0.16.0'
  s.add_runtime_dependency 'celluloid-pmap', '~> 0.2', '~> 0.2.2'
  s.add_runtime_dependency 'slop', '~> 4.2', '>= 4.2.1'
  s.add_runtime_dependency 'activesupport', '~> 4.2', '>= 4.2.5'
  s.add_runtime_dependency 'rubytree', '~> 0.9', '>= 0.9.6'
  s.add_runtime_dependency 'tilt', '~> 1.4', '>= 1.4.1'

  s.add_development_dependency 'rake', '>= 3.3', '>= 3.3'
  s.add_development_dependency 'rspec', '~> 3.3', '>= 3.3'
  s.add_development_dependency 'simplecov', '~> 0.10', '>= 0.10'
  s.add_development_dependency 'simplecov-summary', '~> 0.0.4', '>= 0.0.4'
  s.add_development_dependency 'mocha', '~> 1.1', '>= 1.1'

  s.add_development_dependency 'rubocop', '~> 0.33', '>= 0.33'
  s.add_development_dependency 'reek', '~> 3.7', '>= 3.7'
  s.add_development_dependency 'yard', '~> 0.8', '>= 0.8.7'
  s.add_development_dependency 'yard-rspec', '~> 0.1', '>= 0.1'
  s.add_development_dependency 'redcarpet', '~> 3.3', '>= 3.3'
  s.add_development_dependency 'github-markup', '~> 1.3', '>= 1.3.3'
end
