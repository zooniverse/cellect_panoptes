require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

namespace :db do
  task :load_db_settings do
    require 'active_record'
    user = `whoami`.chomp
    ENV['DATABASE_NAME'] ||= "cellect_panoptes_test"
    ENV['DATABASE_URL'] ||= "postgres://#{user}:#{ENV['DATABASE_PASSWORD'] || user}@localhost:5432/#{ENV['DATABASE_NAME']}"
  end

  task :drop => :load_db_settings do
    `dropdb #{ENV['DATABASE_NAME']}`
  end

  task :create => :load_db_settings do
    `createdb #{ENV['DATABASE_NAME']}`
  end

  task :migrate => :load_db_settings do
    ActiveRecord::Base.establish_connection

    ActiveRecord::Base.connection.create_table :workflows, force: true do |t|
      t.boolean :prioritized
      t.boolean :pairwise
      t.boolean :grouped
    end

    ActiveRecord::Base.connection.create_table :subject_sets, force: true do |t|
      t.integer :workflow_id
    end

    ActiveRecord::Base.connection.create_table :set_member_subjects, force: true do |t|
      t.integer :subject_set_id
      t.integer :subject_id
      t.float :priority
      t.integer :state
    end

    ActiveRecord::Base.connection.create_table :user_seen_subjects, force: true do |t|
      t.integer :user_id
      t.integer :workflow_id
      t.integer :subject_ids, array: true
    end
  end
end
