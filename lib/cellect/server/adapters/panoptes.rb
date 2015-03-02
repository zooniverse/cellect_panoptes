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
          workflow_data = with_connection do
            PanoptesAssociation::Workflow
                             .select(:id, :prioritized, :pairwise, :grouped)
                             .where(id: names)
          end
          workflow_data.map do |row|
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
          subject_data = with_connection do
            PanoptesAssociation::SetMemberSubject.joins(:subject_set)
            .where(subject_sets: { workflow_id: workflow_name },
                   state: 0)
            .select(:subject_id, :priority, :subject_set_id)
          end
          subject_data.map do |row|
            {
              'id' => row.subject_id,
              'priority' => row.priority,
              'group_id' => row.subject_set_id
            }
          end
        end

        def load_user(workflow_name, user_id)
          with_connection do
            subject_ids = PanoptesAssociation::UserSeenSubject
                            .where(workflow_id: workflow_name,
                                   user_id: user_id)
                            .pluck(:subject_ids)
            subject_ids.flatten!
          end
        end

        private

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

        def with_connection(&block)
          ActiveRecord::Base.connection_pool.with_connection &block
        end
      end
    end
  end
end
