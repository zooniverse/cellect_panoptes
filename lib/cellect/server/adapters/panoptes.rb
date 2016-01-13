module Cellect
  module Server
    module Adapters
      module PanoptesAssociation
        class Workflow < ActiveRecord::Base
          has_many :subject_sets_workflows
          has_many :subject_sets, through: :subject_sets_workflows
        end

        class SubjectSetsWorkflow < ActiveRecord::Base
          belongs_to :workflow
          belongs_to :subject_set
        end

        class SubjectSet < ActiveRecord::Base
          has_many :subject_sets_workflows
          has_many :workflows, through: :subject_sets_workflows
          has_many :set_member_subjects
          has_many :subjects, through: :set_member_subjects
        end

        class SetMemberSubject < ActiveRecord::Base
          belongs_to :subject_set
          belongs_to :subject
          has_many :workflows, through: :subject_set
        end

        class UserSeenSubject < ActiveRecord::Base
        end
      end

      class Panoptes < Default
        def status
          { connected: ActiveRecord::Base.connected? }
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

        def load_data_for(workflow_id)
          subject_data = with_connection do
            PanoptesAssociation::SetMemberSubject
              .joins(:workflows)
              .where(workflows: {id: workflow_id})
              .joins("LEFT OUTER JOIN subject_workflow_counts ON subject_workflow_counts.subject_id = set_member_subjects.subject_id")
              .where('subject_workflow_counts.retired_at IS NULL')
              .select(:subject_id, :priority, :subject_set_id)
          end

          subject_data.map do |row|
            {
              'id' => row.subject_id,
              'priority' => 1 / (row.priority || 1).to_f,
              'group_id' => row.subject_set_id
            }
          end
        end

        def load_user(workflow_name, user_id)
          with_connection do
            subject_ids = PanoptesAssociation::UserSeenSubject
              .where(workflow_id: workflow_name, user_id: user_id)
              .pluck(:subject_ids)
            subject_ids.flatten!
          end
        end

        def with_connection(&block)
          ActiveRecord::Base.connection_pool.with_connection &block
        end
      end
    end
  end
end
