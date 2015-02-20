require 'active_record'

module Cellect
  module Server
    module Adapters
      module PanoptesAssociation
        class Workflow < ActiveRecord::Base
          has_many :subject_sets
        end

        class SubjectSet < ActiveRecord::Base
          belongs_to :workflow
          has_many :set_member_subjects
        end

        class SetMemberSubject < ActiveRecord::Base
          belongs_to :subject_set
        end

        class UserSeenSubject < ActiveRecord::Base
        end
      end

      class Panoptes < Default

        DEFAULT_POOL_SIZE = 8

        def initialize
          ActiveRecord::Base.establish_connection(**connection_options)
        end

        def workflow_list(*names)
          PanoptesAssociation::Workflow.select(:id, :prioritized, :pairwise, :grouped)
            .where(id: names)
            .map do |row|
            {
              'id' => row.id,
              'name' => "#{row.id}",
              'prioritized' => row.prioritized,
              'pairwise' => row.pairwise,
              'grouped' => row.grouped
            }
          end
        end

        def load_data_for(workflow_name)
          PanoptesAssociation::SetMemberSubject.joins(:subject_set)
            .where(subject_sets: { workflow_id: workflow_name },
                   state: 0)
            .select(:subject_id, :priority, :subject_set_id)
            .map do |row|
            {
              'id' => row.subject_id,
              'priority' => row.priority,
              'group_id' => row.subject_set_id
            }
          end
        end

        def load_user(workflow_name, user_id)
          PanoptesAssociation::UserSeenSubject.where(workflow_id: workflow_name,
                                user_id: user_id)
            .select(:subject_ids)
            .map do |row|
            row.subject_ids
          end
        end

        def connection_options
          {
            adapter: "postgresql",
            host: ENV.fetch('PG_HOST', '127.0.0.1'),
            port: ENV.fetch('PG_PORT', '5432'),
            dbname: ENV.fetch('PG_DB', 'cellect'),
            user: ENV.fetch('PG_USER', 'cellect'),
            password: ENV.fetch('PG_PASS', ''),
            pool: connection_pool_value
          }
        end

        def connection_pool_value
          pool_val = ENV.fetch('PG_POOL', DEFAULT_POOL_SIZE).to_s
          if ['', '0'].include?(pool_val)
            DEFAULT_POOL_SIZE
          else
            pool_val.to_s
          end
        end
      end
    end
  end
end
