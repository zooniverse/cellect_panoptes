require 'active_record'

module Database
  def self.connect
    current_user = `whoami`.chomp
    ENV['PG_USER'] ||= current_user 
    ENV['PG_DB'] ||= "cellect_panoptes_test"
    ENV['PG_PASS'] ||= current_user 
  end
end
