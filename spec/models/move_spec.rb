require 'spec_helper'

describe Move do
  context 'notification' do
    it "should occur after create" do
      Move.should_receive(:notify).and_return(true)
      Factory :move
    end

    it "should use table name as notice channel" do
      Move.connection.should_receive(:notify).with('moves').and_return(true)
      Move.send(:notify)
    end
  end

  context "listening" do

    it "can be started" do
      Move.connection.should_receive(:listen).with('moves').and_return(true)
      Move.listen!
    end
    it "can be stopped" do
      Move.connection.should_receive(:unlisten).with('moves').and_return(true)
      Move.unlisten!
    end

  end
  it "should be able to lock a job"
end
