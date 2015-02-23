#!/usr/bin/env ruby
require_relative '../cellect_env'
require 'pg'
require 'csv'

class BootstrapPanoptes
  include CellectEnv

  DATA_DIR = 'tmp'
  SUBJECT_DIST = 500000
  FILE_PREFIX = "#{DATA_DIR}/#{SUBJECT_DIST}"

  def initialize
    setup_env_vars
  end

  def create_csv_data
    create_subjects_and_subject_set_csv_data
    create_workflow
    # create_user_seen_subjects
  end

  def create_db_schema
    connect_to_pg
    @pg.exec <<-SQL
      DROP TABLE IF EXISTS workflows;
      CREATE TABLE workflows (
        "id" SERIAL NOT NULL,
        "display_name" varchar(255) NOT NULL,
        "project_id" int NOT NULL,
        "grouped" boolean DEFAULT FALSE,
        "prioritized" boolean DEFAULT FALSE,
        "pairwise" boolean DEFAULT FALSE,
        "classification_count" int DEFAULT 0,
        PRIMARY KEY ("id")
      );

      DROP TABLE IF EXISTS subject_sets;
      CREATE TABLE subject_sets (
        "id" SERIAL NOT NULL,
        "display_name" varchar(255) NOT NULL,
        "project_id" int NOT NULL,
        "workflow_id" int NOT NULL,
        "retirement" json DEFAULT '{ "criteria": "classification_count", "options": { "count": "15" } }',
        "set_member_subjects_count" int DEFAULT 0,
        PRIMARY KEY ("id")
      );

      DROP TABLE IF EXISTS set_member_subjects;
      CREATE TABLE set_member_subjects (
        "id" SERIAL NOT NULL,
        "subject_set_id" int DEFAULT NULL,
        "subject_id" int DEFAULT NULL,
        "priority" decimal NOT NULL DEFAULT 0.0,
        "state" int DEFAULT 0,
        "classification_count" int DEFAULT 0,
        PRIMARY KEY ("id")
      );

      DROP TABLE IF EXISTS user_seen_subjects;
      CREATE TABLE user_seen_subjects (
        "id" SERIAL NOT NULL,
        "subject_ids" int[] NOT NULL,
        "workflow_id" int DEFAULT NULL,
        "user_id" int NOT NULL,
        PRIMARY KEY ("id")
      );
    SQL
  end

  def load_csv_data
    connect_to_pg
    @pg.exec <<-SQL
      COPY workflows(id,display_name,project_id,grouped,prioritized,pairwise,classification_count)
        FROM '/#{FILE_PREFIX}/workflows.csv' DELIMITER ',' NULL AS 'NULL' CSV;
      COPY subject_sets(id,display_name,project_id,workflow_id,set_member_subjects_count)
        FROM '/#{FILE_PREFIX}/subject_sets.csv' DELIMITER ',' NULL AS 'NULL' CSV;
      COPY set_member_subjects(id,subject_set_id,subject_id,priority,state,classification_count)
        FROM '/#{FILE_PREFIX}/set_member_subjects.csv' DELIMITER ',' NULL AS 'NULL' CSV;
    SQL
  end

  def list_csv_data
    csv_files = File.join("tmp/**/*")
    p Dir.glob(csv_files)
  end

  private

  def connect_to_pg
    @pg ||= PG.connect host: @pg_host, port: @pg_port,
                       dbname: @pg_db, user: @pg_user,
                       password: @pg_pass
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

  def create_subjects_and_subject_set_csv_data
    puts "Creating subject_set and subjects CSV files\n"
    subjects = []
    active_default_state = 0
    subject_set = [1,"Stargazing",1,1,SUBJECT_DIST]
    1.upto(SUBJECT_DIST).each do |subject_id|
      subject_priority = priority_for_data_import(subject_id)
      subjects << [subject_id, 1, subject_id, subject_priority, active_default_state,0]
    end

    CSV.open("#{FILE_PREFIX}/subject_sets.csv", "wb") { |csv| csv << subject_set }
    CSV.open("#{FILE_PREFIX}/set_member_subjects.csv", "wb") do |csv|
      subjects.each { |subject_row| csv << subject_row }
    end
  end

  def create_workflow
    puts "Creating workflow CSV file\n"
    workflow = [1, "Stargazing Workflow", 1, false, true, false, 0]
    CSV.open("#{FILE_PREFIX}/workflows.csv", "wb") { |csv| csv << workflow }
  end
end
