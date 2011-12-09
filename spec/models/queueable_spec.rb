require 'spec_helper'

describe Queueable do
  it "should be a module" do
    described_class.should be_a(Module)
  end

  context "included in model" do
    let(:model) {
      Class.new(ActiveRecord::Base).tap do |model|
        model.set_table_name 'modls'
      end
    }
    let(:connection) { mock('ConnectionAdapter') }
    before do
      model.stub(:connection).and_return(connection)
      model.send(:include, described_class)
    end

    it "should use table name as notice channel" do
      connection.should_receive(:notify).with('modls').and_return(true)
      model.send(:notify)
    end

    it "can start listening" do
      connection.should_receive(:listen).with('modls').and_return(true)
      model.listen!
    end
    it "can stop listening" do
      connection.should_receive(:unlisten).with('modls').and_return(true)
      model.unlisten!
    end

    it "should add scope: locked"

    it "can wait for a new record using PostgreSQLAdapter#wait_for_notify" do
      model.should respond_to(:wait_for_new_record)
      model.should_receive(:listen!)
      model.should_receive(:unlisten!)
      connection.should_receive(:wait_for_notify).with(23).and_return(true)
      model.wait_for_new_record(23)
    end

    it "indicates that the correct event was received" do
      pending "needs an actual connection, tested in implemented model for now"
      model.listen!
      model.send(:notify)
      model.wait_for_new_record(1).should be_true
    end


  end

  it "should be able to lock a job"
end
