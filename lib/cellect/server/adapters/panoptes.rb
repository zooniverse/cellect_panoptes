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

        class SubjectWorkflowCount < ActiveRecord::Base
          belongs_to :subject
          belongs_to :workflow
        end
      end

      class Panoptes < Default
        def status
          { connected: ActiveRecord::Base.connected? }
        end

        def workflow_list(*names)
          with_connection do
            workflow_data = PanoptesAssociation::Workflow
              .select(:id, :prioritized, :pairwise, :grouped)
              .where(id: names)

            [].tap do |rows|
              workflow_data.find_each do |w|
                rows << {
                  'id' => w.id,
                  'name' => "#{w.id}",
                  'prioritized' => w.prioritized,
                  'pairwise' => w.pairwise,
                  'grouped' => w.grouped
                }
              end
            end
          end
        end

        def load_data_for(workflow_id)
          with_connection do
            subject_data_scope = PanoptesAssociation::SetMemberSubject
              .joins(:workflows)
              .where(workflows: {id: workflow_id})
              .joins(
                "LEFT OUTER JOIN subject_workflow_counts " \
                "ON subject_workflow_counts.subject_id = set_member_subjects.subject_id"
              )
              .where('subject_workflow_counts.workflow_id': workflow_id)
              .where('subject_workflow_counts.retired_at IS NULL')
              .select(:id, :subject_id, :priority, :subject_set_id)

            subject_data_scope.find_each do |s|
              row = {
                'id' => s.subject_id,
                'priority' => 1 / (s.priority || 1).to_f,
                'group_id' => s.subject_set_id
              }
              yield row
            end
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
