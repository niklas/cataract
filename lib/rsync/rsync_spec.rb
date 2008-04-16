require 'rsync'
describe Rsync do
  it "should respond to .copy" do
    Rsync.should respond_to(:copy)
  end
  it "should respond to .command" do
    Rsync.should respond_to(:command)
  end
  it "should respond to .parse" do
    Rsync.should respond_to(:parse)
  end
end

describe "Syncing lots of small files" do
  before(:each) do
    @log = File.open('rsync-foo.log')
    @total = 6734
    @max_step = 101.0/@total
  end
  it "should parse the log" do
    old_progress = 0.0
    Rsync.parse(@log) do |progress,current_file|
      (progress-old_progress).should >= -0.00001 # damned floats
      (progress-old_progress).should <= @max_step
      old_progress = progress
    end
  end
  after(:each) do
    @log.close
  end
end

describe "Syncing some epsisodes (unfinished)" do
  before(:each) do
    @log = File.open('rsync-niptuck-unfinished.log')
    @total = 15
    @max_step = 100.0/@total
  end
  it "should parse the log" do
    old_progress = 0.0
    Rsync.parse(@log) do |progress,current_file,progress_file|
      progress.should >= old_progress
      unless current_file == '[done]'
        (progress-old_progress).should <= @max_step 
      end
      old_progress = progress
    end
  end
  after(:each) do
    @log.close
  end
end
