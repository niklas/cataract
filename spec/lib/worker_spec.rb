require 'spec_helper'
require 'worker'

describe Worker do
  it "can start" do
    worker = mock('Worker')
    Worker.should_receive(:new).and_return(worker)
    worker.should_receive(:start)
    Worker.start
  end

  it "needs a channel to listen" do
    expect { Worker.new }.to raise_error(ArgumentError)
    expect { Worker.new('foo') }.not_to raise_error
  end

  it "should know the channel to listen to" do
    worker = Worker.new('fnords')
    worker.channel.should == 'fnords'
  end

  context "with a channel" do
    subject { Worker.new('fnords') }

    context 'starting' do
      it "should handle signals" do
        subject.should_receive(:handle_signals)
        subject.start
      end
    end

    context 'started' do
      before do
        subject.stub(:handle_signals) # may confuse rspec
        subject.start
      end

      it { should be_running }
    end


  end
end
