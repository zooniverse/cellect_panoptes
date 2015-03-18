require 'newrelic_rpm'
require 'cellect/server'
require_relative 'lib/cellect/server/adapters/panoptes'

Cellect::Server.adapter = Cellect::Server::Adapters::Panoptes.new

# provide the ability to preload workflow data sets on boot
workflows_to_load_on_boot = ENV['PRELOAD_WORKFLOWS']
workflows_to_load_on_boot.split(",").each do |workflow_id|
  puts "Preloading workflow: #{workflow_id}"
  Cellect::Server.adapter.load_workflows(workflow_id)
end

run Cellect::Server::API
