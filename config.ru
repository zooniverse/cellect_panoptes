require 'cellect/server'
require 'cellect/server/adapters/postgres'

class PanoptesAdapter < Cellect::Server::Adapters::Postgres
  def load_data_for(workflow_name)
    with_pg do |pg|
      statement = <<-SQL
SELECT sms.id as id, sms.priority as priority, sms.subject_set_id as group_id
FROM workflows w
JOIN subject_sets ss ON (ss.workflow_id = w.id)
JOIN set_member_subjects sms ON (sms.subject_set_id = ss.id)
WHERE w.id = #{ workflow_name } AND sms.state = 0
SQL
      pg.exec(statement).collect do |row|
        {
          'id' => row['id'].to_i,
          'priority' => row['priority'].to_f,
          'group_id' => row['group_id'].to_i
        }
      end
    end
  end
end

Cellect::Server.adapter = PanoptesAdapter.new

run Cellect::Server::API
