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
    subject   {
      Worker.new('fnords').tap do |worker|
        worker.stub(:wait).and_return(true)
      end
    }
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

      context "on last attempt" do
        before do
          subject.should_receive(:next_job).exactly(4).times.and_return(nil)
          subject.should_receive(:next_job).once.and_return(job)
        end

        it "tries at least 5 times" do
          subject.lock_job.should == job
        end

        it "waits between failures" do
          subject.should_receive(:wait).exactly(4).times
          subject.lock_job
        end

        it "increases waiting time between failures" do
          subject.should_receive(:wait).once.with(1)
          subject.should_receive(:wait).once.with(2)
          subject.should_receive(:wait).once.with(4)
          subject.should_receive(:wait).once.with(8)
          subject.lock_job
        end
      end

      it "raises if tried 5 times without success" do
        subject.should_receive(:next_job).exactly(5).times.and_return(nil)
        expect { subject.lock_job }.to raise_error
      end

    end

    context "waiting" do
      it "waits for notify from the db"
      it "falls back to sleep if cannot/should_not listen"
    end
  end
end

