require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'vcr_setup'

require 'rspec/autorun'
require 'sisow'

RSpec.configure do |config|
  config.mock_with :rspec
  config.color_enabled = true
  config.tty = true
  config.formatter = :progress

  config.before(:each) do
    hash = YAML.load(File.open('./spec/sisow.yml'))

    Sisow.configure do |config|
      config.merchant_id  = hash['merchant_id']
      config.merchant_key = hash['merchant_key']
      config.test_mode    = true
      config.debug_mode   = false
    end
  end
end
