require 'spec_helper'
require 'cellect/server'
require 'cellect/server/adapters/panoptes'

RSpec.describe Cellect::Server::Adapters::Panoptes do
  subject do
    described_class.new
  end

  let(:workflow_class) { Cellect::Server::Adapters::PanoptesAssociation::Workflow }
  let(:set_class) { Cellect::Server::Adapters::PanoptesAssociation::SubjectSet}
  let(:set_workflow_join_class) { Cellect::Server::Adapters::PanoptesAssociation::SubjectSetsWorkflow}
  let(:subject_class) { Cellect::Server::Adapters::PanoptesAssociation::SetMemberSubject }
  let(:uss_class) { Cellect::Server::Adapters::PanoptesAssociation::UserSeenSubject }

  let(:workflows) do
    w1 = workflow_class.create! do |w|
       w.prioritized = false
       w.pairwise = true
       w.grouped = true
     end

     w2 = workflow_class.create! do |w|
       w.prioritized = true
       w.pairwise = false
       w.grouped = false
     end

     [w1, w2]
  end

  let(:loaded_workflow) { workflows.sample }

  let(:subjects) do
    subject_set = set_class.create! do |set|
      set.display_name = "The Set"
      set.project_id = 1
    end

    ss_workflow = set_workflow_join_class.create! do |ssw|
      ssw.subject_set_id = subject_set.id
      ssw.workflow_id = loaded_workflow.id
    end

    s1 = subject_class.create! do |s|
       s.subject_set_id = subject_set.id
       s.subject_id = 1
       s.priority = 1.234123
       s.random = rand
     end

     s2 = subject_class.create! do |s|
       s.subject_set_id = subject_set.id
       s.subject_id = 2
       s.priority = 1.234123
       s.random = rand
     end

     [s1, s2]
  end

  before(:each) do
    uss_class.destroy_all
    set_workflow_join_class.destroy_all
    set_class.destroy_all
    subject_class.destroy_all
    workflow_class.destroy_all
  end

  describe "ActiveRecord connection" do

    it 'should have started' do
      subject
      expect(ActiveRecord::Base.connection).to_not be_nil
    end

    describe "connection pool value" do
      before(:each) do
        ENV['PG_POOL'] = pool_value
      end

      context "when nil" do
        let(:pool_value) { nil }

        it 'should not raise an error' do
          subject
          expect { ActiveRecord::Base.connection }.not_to raise_error
        end
      end

      context "when blank" do
        let(:pool_value) { '' }

        it 'should not raise an error' do
          subject
          expect { ActiveRecord::Base.connection }.not_to raise_error
        end
      end

      context "when 0" do
        let(:pool_value) { '0' }

        it 'should not raise an error' do
          subject
          expect { ActiveRecord::Base.connection }.not_to raise_error
        end
      end
    end
  end

  describe "#workflow_list" do
    context 'one workflow' do
      it 'should load a workflow with the given id' do
        workflow = workflows.first
        expect(subject.workflow_list(workflow.id).first).to include("id" => workflow.id,
                                                                    "name" => workflow.id.to_s,
                                                                    "prioritized" => workflow.prioritized,
                                                                    "grouped" => workflow.grouped,
                                                                    "pairwise" => workflow.pairwise)
      end
    end

    context 'many workflows' do
      it 'should load all the givien workflows' do
        expect(subject.workflow_list(*workflows.map(&:id)).length).to eq(2)
      end
    end
  end

  describe '#load_data_for' do
    it 'should subject data for the given workflow' do
      subjects # not created yet
      data = subject.load_data_for(loaded_workflow.id).group_by{ |h| h['id'] }

      subjects.each do |panoptes_subject|
        cellect_subject = data[panoptes_subject.subject_id].first
        expect(cellect_subject).to be_present
        expect(cellect_subject['id']).to eql panoptes_subject.subject_id
        expect(cellect_subject['group_id']).to eql panoptes_subject.subject_set_id
        expect(cellect_subject['priority']).to be_within(0.1).of 1 / panoptes_subject.priority.to_f
      end
    end
  end

  describe '#load_user' do
    it 'should load the subjects a user has seen' do
      uss_class.create! do |u|
        u.workflow_id = 1
        u.user_id = 1
        u.subject_ids = [1,2,3,4]
      end
      expect(subject.load_user(1, 1)).to eq([1, 2, 3, 4])
    end
  end
end
