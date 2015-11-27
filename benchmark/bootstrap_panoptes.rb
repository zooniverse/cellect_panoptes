#!/usr/bin/env ruby
require_relative '../cellect_env'
require 'pg'
require 'csv'

class BootstrapPanoptes
  include CellectEnv

  DATA_DIR = 'tmp'
  SUBJECT_DIST = 500000
  FILE_PREFIX = "#{DATA_DIR}/#{SUBJECT_DIST}"
  USER_COUNT = 10_000
  RETIREMENT_COUNT = 15
  PROJECT_ID = 1
  WORKFLOW_ID = 1
  STD_USER_CLASSIFICATION_COUNT = 15
  POWER_USER_IDS = [ 3685, 9616, 4013, 6538, 1863 ]
  POWER_USER_SET_SIZE = 0.85
  CSV_QUOTE_CHAR = "'"

  def initialize
    setup_env_vars
  end

  def load_csv_data
    connect_to_pg

    puts 'loading workflows...'
    @pg.exec <<-SQL
      COPY workflows(id,display_name,project_id,grouped,prioritized,pairwise,classifications_count,updated_at,created_at)
        FROM '/#{FILE_PREFIX}/workflows.csv' DELIMITER ',' NULL AS 'NULL' CSV;
    SQL

    puts 'loading subject_sets...'
    @pg.exec <<-SQL
      COPY subject_sets(id,display_name,project_id,set_member_subjects_count,updated_at,created_at)
        FROM '/#{FILE_PREFIX}/subject_sets.csv' DELIMITER ',' NULL AS 'NULL' CSV;
    SQL

    puts 'loading subject_sets_workflows...'
    @pg.exec <<-SQL
      COPY subject_sets_workflows(id,workflow_id,subject_set_id)
        FROM '/#{FILE_PREFIX}/subject_sets_workflows.csv' DELIMITER ',' NULL AS 'NULL' CSV;
    SQL

    puts 'loading set_member_subjects...'
    @pg.exec <<-SQL
      COPY set_member_subjects(id,subject_set_id,subject_id,priority,random,updated_at,created_at)
        FROM '/#{FILE_PREFIX}/set_member_subjects.csv' DELIMITER ',' NULL AS 'NULL' CSV;
    SQL

    puts 'loading user_seen_subjects...'
    @pg.exec <<-SQL
      COPY user_seen_subjects(id,subject_ids,workflow_id,user_id,updated_at,created_at)
          FROM '/#{FILE_PREFIX}/user_seen_subjects.csv' DELIMITER ',' NULL AS 'NULL' CSV;
    SQL

    puts 'creating indexes...'
    @pg.exec <<-SQL
      CREATE INDEX index_workflows_on_project_id ON workflows(project_id);
      CREATE INDEX index_subject_sets_on_project_id ON subject_sets(project_id);
      CREATE INDEX index_subject_sets_on_subject_set_id_and_workflow_id ON subject_sets_workflows(subject_set_id, workflow_id);
      CREATE INDEX index_set_member_subjects_on_subject_id ON set_member_subjects(subject_id);
      CREATE INDEX index_set_member_subjects_on_subject_set_id ON set_member_subjects(subject_set_id);
      CREATE INDEX index_user_seen_subjects_on_user_id_and_workflow_id ON user_seen_subjects(user_id, workflow_id);
      CREATE INDEX index_user_seen_subjects_on_workflow_id ON user_seen_subjects(workflow_id);
    SQL
  end

  def list_csv_data
    csv_files = File.join("#{ DATA_DIR }/**/*")
    p Dir.glob(csv_files)
  end

  def create_csv_data
    setup_csv_output_dir
    puts "Creating synthetic CSV data files\n"

    puts "Creating workflow data file\n"
    tstamps = DateTime.now
    workflow = [1,"Stargazing Workflow",PROJECT_ID,false,true,false,0,tstamps,tstamps]
    CSV.open("#{FILE_PREFIX}/workflows.csv", "wb") { |csv| csv << workflow }

    puts "Creating subject_set data file\n"
    tstamps = DateTime.now
    subject_set = [1,"Stargazing",PROJECT_ID,SUBJECT_DIST,tstamps,tstamps]
    CSV.open("#{FILE_PREFIX}/subject_sets.csv", "wb") { |csv| csv << subject_set }

    puts "Creating subject_set_workflows data file\n"
    subject_set_workflow = [1, WORKFLOW_ID, subject_set.first]
    CSV.open("#{FILE_PREFIX}/subject_sets_workflows.csv", "wb") { |csv| csv << subject_set_workflow }

    puts "Creating set_member_subjects data file\n"

    CSV.open("#{FILE_PREFIX}/set_member_subjects.csv", "wb") do |csv|
      1.upto(SUBJECT_DIST).each do |subject_id|
        subject_priority = priority_for_data_import(subject_id)
        tstamps = DateTime.now
        csv << [subject_id,1,subject_id,subject_priority,rand,tstamps,tstamps]
      end
    end

    puts "Creating user_seen_subjects data file\n"
    user_seen_subjects = create_synthetic_user_seen_data

    CSV.open("#{FILE_PREFIX}/user_seen_subjects.csv", "wb", quote_char: CSV_QUOTE_CHAR) do |csv|
      user_seen_subjects.each { |uss_row| csv << uss_row }
    end
  end

  private

  def connect_to_pg
    @pg ||= PG.connect host: @pg_host, port: @pg_port,
                       dbname: @pg_db, user: @pg_user,
                       password: @pg_pass
  end

  def setup_csv_output_dir
    unless File.directory?(FILE_PREFIX)
      FileUtils.mkdir_p(FILE_PREFIX)
    end
  end

  def priority_for_data_import(subject_id)
    case
    when subject_id <= 150000
      0.1
    when subject_id <= 300000
      0.5
    else
      0.9
    end
  end

  def create_synthetic_user_seen_data
    user_seen_subjects = []
    user_seen_distribution = setup_user_seen_distribution
    subject_ids = (1..SUBJECT_DIST).to_a
    stargazing_user_ids = (1..USER_COUNT).to_a
    uss_id_offset = 1

    #a number of classifications for each user
    STD_USER_CLASSIFICATION_COUNT.times do
      stargazing_user_ids.each do |uss_id|
        next if POWER_USER_IDS.include?(uss_id)
        user_seen_range = user_seen_distribution.sample
        seen_count = user_seen_range[0] + rand(user_seen_range[1])
        seen_id = subject_ids.sample
        user_id = uss_id
        tstamps = DateTime.now
        user_seen_subjects << [uss_id_offset, "\"{#{ seen_id }}\"", WORKFLOW_ID, user_id, tstamps, tstamps]
        uss_id_offset += 1
      end
    end

    #power users and the long tail
    percent_complete = (SUBJECT_DIST * POWER_USER_SET_SIZE).to_i
    subject_ids.sample(percent_complete).each do |subject_id|
      long_tail_user_ids = stargazing_user_ids.sample(long_tail_user_count)
      (POWER_USER_IDS | long_tail_user_ids).each do |user_id|
        tstamps = DateTime.now
        user_seen_subjects << [uss_id_offset, "\"{#{ subject_id }}\"", WORKFLOW_ID, user_id, tstamps, tstamps]
        uss_id_offset += 1
      end
    end
    puts "\n\nPower user ids: #{POWER_USER_IDS.join(", ")}\nUse these in your cellect benchmarking.\n"
    user_seen_subjects
  end

  def setup_user_seen_distribution
    [].tap do |user_seen_distribution|
      380.times{ user_seen_distribution << [    1,      10] }
      180.times{ user_seen_distribution << [   10,      20] }
      230.times{ user_seen_distribution << [   20,      50] }
       90.times{ user_seen_distribution << [   50,     100] }
      100.times{ user_seen_distribution << [  100,   1_000] }
       17.times{ user_seen_distribution << [1_000,  10_000] }
        3.times{ user_seen_distribution << [10_000, 50_000] }
    end
  end

  def long_tail_user_count
    (1..RETIREMENT_COUNT).to_a.sample
  end
end
