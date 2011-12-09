require 'spec_helper'

describe Move do

  it "should notify after create" do
    Move.should_receive(:notify).and_return(true)
    Factory :move
  end

  context "out of a transaction", without_transaction: true do
    context "waiting for new record" do
      it "indicates that the correct event was received" do
        notification = Thread.new do
          sleep 0.5
          Move.send(:notify)
        end
        Move.wait_for_new_record(10).should be_true
      end
    end
  end

end
