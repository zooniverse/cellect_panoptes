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

        def workflow_list(*names)
          workflow_data = PanoptesAssociation::Workflow
          .select(:id, :prioritized, :pairwise, :grouped)
          .where(id: names)

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
          subject_data = PanoptesAssociation::SetMemberSubject.joins(:subject_set)
          .where(subject_sets: { workflow_id: workflow_name }, state: 0)
          .select(:subject_id, :priority, :subject_set_id)

          subject_data.map do |row|
            {
              'id' => row.subject_id,
              'priority' => row.priority,
              'group_id' => row.subject_set_id
            }
          end
        end

        def load_user(workflow_name, user_id)
          subject_ids = PanoptesAssociation::UserSeenSubject
          .where(workflow_id: workflow_name, user_id: user_id)
          .pluck(:subject_ids)
          subject_ids.flatten!
        end
      end
    end
  end
end
