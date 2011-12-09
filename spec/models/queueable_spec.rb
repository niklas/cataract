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
    let(:connection) { model.connection } 
    before do
      model.send(:include, described_class)
    end

    it "should use table name as notice channel" do
      connection.should_receive(:notify).with('modls').and_return(true)
      model.send(:notify)
    end

    it "notifies on create" do
      table_name = "you_hopefully_never_have_to_call_a_table_like_this"
      connection.create_table table_name
      model.set_table_name table_name
      model.should_receive(:notify)
      model.create!
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

    it "indicates that the correct event was received", without_transaction: true do
      # notifications will only be delivered after transactions ends, so we do not even start one
      # see spec_helper!
      notification = Thread.new do
        sleep 0.5
        model.send(:notify)
      end
      model.wait_for_new_record(10).should be_true
      notification.join
    end


  end

  it "should be able to lock a job"
end
