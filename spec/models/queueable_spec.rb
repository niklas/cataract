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

    it "can start listening" do
      connection.should_receive(:listen).with('modls').and_return(true)
      model.listen!
    end
    it "can stop listening" do
      connection.should_receive(:unlisten).with('modls').and_return(true)
      model.unlisten!
    end

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

    it "will timeout when no even was received", without_transaction: true do
      model.wait_for_new_record(0.1).should be_false
    end

    context "with table" do
      let(:table_name) {"you_hopefully_never_have_to_call_a_table_like_this"}
      before do
        connection.create_table table_name do |t|
          t.timestamp :locked_at
        end
        model.set_table_name table_name
      end

      it "notifies on create" do
        model.should_receive(:notify)
        model.create!
      end

      it "should have instances acting like queuable" do
        model.new.should be_acts_like(:queueable)
      end

      context "with some records" do
        before do
          3.times { model.create! }
        end

        it "should set locked_at on locked record" do
          record = model.locked
          record.should be_a(model)
          record.locked_at.should_not be_nil
        end

        it "should fetch no record twice" do
          first, second, third = model.locked, model.locked, model.locked
          first.should_not eql(second)
          first.should_not eql(third)
          second.should_not eql(third)
        end

        it "should not fail if no records left" do
          connection.create_queueable_lock_function
          3.times { model.locked }
          expect { model.locked }.not_to raise_error
        end
      end

      context "#work!" do
        it "should provide saveguard from exceptions"
      end
    end

  end
end
