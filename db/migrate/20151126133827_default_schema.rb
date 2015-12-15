class DefaultSchema < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :display_name
      t.integer :project_id
      t.boolean :grouped, null: false, default: false
      t.boolean :prioritized, null: false, default: false
      t.boolean :pairwise, null: false, default: false
      t.integer :classifications_count, null: false, default: 0
      t.timestamps null: false
    end

    create_table :subject_sets do |t|
      t.string :display_name
      t.integer :project_id
      t.integer :set_member_subjects_count, null: false, default: 0
      t.timestamps null: false
    end

    create_table :subject_sets_workflows do |t|
      t.integer :workflow_id
      t.integer :subject_set_id
    end

    create_table :set_member_subjects do |t|
      t.integer :subject_set_id
      t.integer :subject_id
      t.decimal :priority
      t.decimal :random, null: false
      t.timestamps null: false
    end

    create_table :user_seen_subjects do |t|
      t.integer :user_id
      t.integer :workflow_id
      t.integer :subject_ids, array: true, null: false, default: []
      t.timestamps null: false
    end

    create_table :subject_workflow_counts do |t|
      t.integer :set_member_subject_id
      t.integer :workflow_id
      t.integer :subject_id
      t.integer :classifications_count, null: false, default: 0
      t.timestamp :retired_at
      t.integer :subject_id, null: false
    end
  end
end
