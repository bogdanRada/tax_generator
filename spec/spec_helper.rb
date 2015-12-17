# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'

require 'simplecov'
require 'simplecov-summary'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(SimpleCov::Formatter::HTMLFormatter)

SimpleCov.start 'rails' do
  add_filter 'spec'

  at_exit {}
end




require 'bundler/setup'
require 'tax_generator'
require_relative '../lib/tax_generator/helpers/application_helper'
require 'rspec'
#fake actor class
class Actor
  def self.current
    Struct.new(:link)
  end
end

RSpec.configure do |config|
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.include TaxGenerator::ApplicationHelper

  config.mock_with :mocha

  config.after(:suite) do
    if SimpleCov.running
      SimpleCov::Formatter::HTMLFormatter.new.format(SimpleCov.result)

      SimpleCov::Formatter::SummaryFormatter.new.format(SimpleCov.result)
    end
  end
end

Celluloid.logger = nil

at_exit do
  Celluloid::Actor.all.each do |actor|
    Celluloid::Actor.kill(actor)
  end
end
