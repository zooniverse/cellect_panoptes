require 'active_record'
require 'cellect/server'
require_relative '../lib/cellect/server/adapters/panoptes'
require 'otr-activerecord'
require 'pry'

OTR::ActiveRecord.configure_from_url! ENV['DATABASE_URL']

#ActiveRecord::Base.connection_config
#ActiveRecord::Base.establish_connection
#ActiveRecord::Base.connected?

binding.pry

adapter = Cellect::Server::Adapters::Panoptes.new
adapter.load_data_for 1337
