require 'cellect/server'
require 'cellect/server/adapters/postgres'
Cellect::Server.adapter = Cellect::Server::Adapters::Postgres.new

run Cellect::Server::API
