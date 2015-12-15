require 'bundler'
RACK_ENV = (ENV['RACK_ENV'] || 'test').to_sym
Bundler.require(:default, RACK_ENV)

RSpec.configure do |config|
  config.disable_monkey_patching!
end
