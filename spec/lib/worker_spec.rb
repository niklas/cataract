require 'spec_helper'
require 'worker'

describe Worker do
  it "can start" do
    worker = mock('Worker')
    Worker.should_receive(:new).and_return(worker)
    worker.should_receive(:start).and_return(true)
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

  context "working" do
    subject   { Worker.new('fnords') }
    let(:job_class) { 
      mock('FnordClass').tap do |job_class|
        subject.stub(:job_class).and_return(job_class)
      end
    }
    let(:job) { 
      mock('Job', work: true, destroy: true).tap do |job|
        subject.stub(:next_job).and_return(job)
      end
    }

    it "should lock the job" do
      job_class.should be_present
      subject.should_receive(:lock_job).and_return(nil)
      subject.work
    end

    it "should be delegated to the job" do
      job.should_receive(:work)
      subject.work
    end

    context "successfully" do
      it "should destroy the job" do
        job.should_receive(:destroy)
        subject.work
      end
    end

    context "fail" do
      let(:error) { RuntimeError.new("too many fnords") }
      before do
        subject.stub(:handle_failure)
        job.stub(:work).and_raise(error)
      end
      it "should destroy the job, too" do
        job.should_receive(:destroy)
        subject.work
      end

      it "should be handled with" do
        subject.should_receive(:handle_failure).with(job, error).and_return(true)
        subject.work
      end
    end

    context "failure handling" do
      it "defaults to spit the error out" do
        STDERR.should_receive(:puts).at_least(5).times
        expect { 
          subject.send(:handle_failure, "a job", "error to ignore") 
        }.not_to raise_error
      end
    end

    context "next job" do
      let(:job)       { mock 'a Fnord' }

      it "uses locked scope on job_class to return a job" do
        job_class.stub_chain(:locked, :first).and_return(job)

        subject.next_job.should == job
      end
    end

    context "lock job" do
      let(:job)       { mock 'a Fnord' }

      it "tries at least 3 times" do
        subject.should_receive(:next_job).twice.and_return(nil)
        subject.should_receive(:next_job).once.and_return(job)
        subject.lock_job.should == job
      end
      it "waits between failures"
      it "increases waiting time between failures"

    end

    context "waiting" do
      it "waits for notify from the db"
      it "falls back to sleep if cannot/should_not listen"
    end
  end
end

