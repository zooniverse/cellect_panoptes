require 'newrelic_rpm'
require 'cellect/server'
require_relative 'lib/cellect/server/adapters/panoptes'

Cellect::Server.adapter = Cellect::Server::Adapters::Panoptes.new

run Cellect::Server::API
