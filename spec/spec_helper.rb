require 'bundler'
RACK_ENV = (ENV['RACK_ENV'] || 'test').to_sym
Bundler.require(:default, RACK_ENV)

OTR::ActiveRecord.configure_from_url! ENV['DATABASE_URL']

ActiveRecord::Base.logger.level = 1

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
