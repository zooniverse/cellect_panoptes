# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151126133827) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "set_member_subjects", force: :cascade do |t|
    t.integer  "subject_set_id"
    t.integer  "subject_id"
    t.decimal  "priority"
    t.decimal  "random",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "subject_sets", force: :cascade do |t|
    t.string   "display_name"
    t.integer  "project_id"
    t.integer  "set_member_subjects_count", default: 0, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "subject_sets_workflows", force: :cascade do |t|
    t.integer "workflow_id"
    t.integer "subject_set_id"
  end

  create_table "subject_workflow_counts", force: :cascade do |t|
    t.integer  "set_member_subject_id"
    t.integer  "workflow_id"
    t.integer  "subject_id",                        null: false
    t.integer  "classifications_count", default: 0, null: false
    t.datetime "retired_at"
  end

  create_table "user_seen_subjects", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "workflow_id"
    t.integer  "subject_ids", default: [], null: false, array: true
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "workflows", force: :cascade do |t|
    t.string   "display_name"
    t.integer  "project_id"
    t.boolean  "grouped",               default: false, null: false
    t.boolean  "prioritized",           default: false, null: false
    t.boolean  "pairwise",              default: false, null: false
    t.integer  "classifications_count", default: 0,     null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

end
