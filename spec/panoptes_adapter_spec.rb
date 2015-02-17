require 'spec_helper'
require 'cellect/server'
require 'cellect/server/adapters/panoptes'

RSpec.describe Cellect::Server::Adapters::Panoptes do
  subject do
    described_class.new
  end

  let(:workflow_class) { Cellect::Server::Adapters::PanoptesAssociation::Workflow }
  let(:set_class) { Cellect::Server::Adapters::PanoptesAssociation::SubjectSet}
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

  let(:subjects) do
    subject_set = set_class.create! do |set|
      set.workflow_id = 1
    end

    s1 = subject_class.create! do |s|
       s.subject_set_id = subject_set.id
       s.subject_id = 1
       s.state = 0
       s.priority = 1.234123
     end

     s2 = subject_class.create! do |s|
       s.subject_set_id = subject_set.id
       s.subject_id = 2
       s.state = 1
       s.priority = 1.234123
     end

     [s1, s2]
  end

  after(:each) do
    workflow_class.destroy_all
    set_class.destroy_all
    subject_class.destroy_all
    uss_class.destroy_all
  end

  it 'should have started an ActiveRecord connection' do
    subject
    expect(ActiveRecord::Base.connection).to_not be_nil
  end

  describe "#workflow_list" do
    context 'one workflow' do
      it 'should load a workflow with the given id' do
        workflow = workflows.first
        expect(subject.workflow_list(workflow.id).first).to include("id" => workflow.id,
                                                                    "name" => workflow.id,
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
      active_sub = subjects.first
      expect(subject.load_data_for(1)).to include("id" => active_sub.subject_id,
                                                  "priority" => active_sub.priority,
                                                  "group_id" => active_sub.subject_set_id)
    end
  end

  describe '#load_user' do
    it 'should load the subjects a user has seen' do
      uss_class.create! do |u|
        u.workflow_id = 1
        u.user_id = 1
        u.subject_ids = [1,2,3,4]
      end
      expect(subject.load_user(1, 1)).to eq([[1, 2, 3, 4]])
    end
  end
end
