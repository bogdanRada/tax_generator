require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'yard-rspec'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--backtrace '] if ENV['DEBUG']
end

YARD::Config.options[:load_plugins] = true
YARD::Config.load_plugins

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'spec/**/*_spec.rb'] # optional
  t.options = ['--any', '--extra', '--opts', '--markup-provider=redcarpet', '--markup=markdown', '--debug'] # optional
  t.stats_options = ['--list-undoc'] # optional
end

desc 'Default: run the unit tests.'
task default: [:all]

desc 'Test the plugin under all supported Rails versions.'
task :all do |_t|
  exec('bundle exec rubocop . && bundle exec inch --pedantic && bundle exec yard && bundle exec rake spec')
end
