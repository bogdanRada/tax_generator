# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'

require 'simplecov'
require 'simplecov-summary'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(SimpleCov::Formatter::HTMLFormatter)

SimpleCov.start 'rails' do
  add_filter 'spec'

  at_exit {}
end

# fake class to use for elements that need atlas id as attribute
AtlasID = Struct.new(:value)

# fake class to use for elements that need atlas id as attribute
FakeNode = Struct.new(:value)

#fake class for tilt
class FakeTilt

  def render(*args) end
end

require 'bundler/setup'
require 'tax_generator'
require_relative '../lib/tax_generator/helpers/application_helper'
require 'rspec'
# fake class for actors
class Actor
  def self.current
  end
end

class FakeCelluloidCondition

  def signal
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
