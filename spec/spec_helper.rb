require 'bundler/setup'
Bundler.require(:development)

require 'support/database'

Database.connect

RSpec.configure do |config|
  config.disable_monkey_patching!
end
