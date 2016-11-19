$LOAD_PATH.unshift File.expand_path("../../src", __FILE__)
require 'cabot/cabot'
require 'cabot/version'
require 'cabot/core/command_processor'

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
