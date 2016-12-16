require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])
require_relative 'lib/cellect/server/adapters/panoptes'

use Rack::CommonLogger, STDOUT

OTR::ActiveRecord.configure_from_url! ENV['DATABASE_URL']

use ActiveRecord::ConnectionAdapters::ConnectionManagement

Cellect::Server.adapter = Cellect::Server::Adapters::Panoptes.new

# provide the ability to preload workflow data sets on boot
workflows_to_load_on_boot = ENV['PRELOAD_WORKFLOWS']
workflows_to_load_on_boot.split(",").each do |workflow_id|
  puts "Preloading workflow: #{workflow_id}"
  Cellect::Server.adapter.load_workflows(workflow_id)
end

# Mark this server as active through Redis
Cellect::Server.connect
run Cellect::Server::API
