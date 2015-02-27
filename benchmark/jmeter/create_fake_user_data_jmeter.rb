#!/usr/bin/env ruby
require 'csv'
require_relative '../bootstrap_panoptes'

PER_API_USER_SIZE = 1000

user_ids = (1..BootstrapPanoptes::USER_COUNT).to_a
random_user_ids = user_ids.sample(PER_API_USER_SIZE)

script_dir = File.expand_path File.dirname(__FILE__)
CSV.open("#{script_dir}/per_api_user_ids.csv", "wb") do |csv|
  random_user_ids.each { |user_id_row| csv << [ user_id_row ] }
end
