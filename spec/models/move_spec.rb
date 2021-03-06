require 'spec_helper'

describe Move do
  it "be marked as acting like queuable" do
    Move.new.should be_acts_like(:queueable)
  end

  context "in filesystem" do
    let(:disk)     { create :disk }
    let(:incoming) { Pathname.new 'incoming' }
    let(:archive)  { Pathname.new 'archive' }

    let(:source)   { create :existing_directory, relative_path: incoming, disk: disk }
    let(:target_directory)   { create :existing_directory, relative_path: archive, disk: disk }

    it "has directoy structure to work on" do
      source.should be_persisted
      source.full_path.should exist_as_directory
      source.full_path.should == source.disk.path/incoming
      target_directory.should be_persisted
      target_directory.full_path.should  exist_as_directory
      target_directory.full_path.should == target_directory.disk.path/archive
    end

    let(:single) do
      build :torrent_with_picture_of_tails, content_directory: source do |torrent|
        create_file source.full_path/'tails.png'
        torrent
      end
    end

    it "should move single file" do
      move = build :move, torrent: single, target_directory: target_directory
      (source.full_path/'tails.png').should exist_as_file
      move.work!
      (source.full_path/'tails.png').should_not exist_as_file
      (target_directory.full_path/'tails.png').should exist_as_file
      single.content_directory.should == target_directory
      single.should be_persisted
      single.changes.should be_empty
    end

    let(:content_dir) { source.full_path/'content' } # directory name from torrent itself

    let(:multiple) do
      build :torrent_with_picture_of_tails_and_a_poem, content_directory: source do |torrent|
        create_directory content_dir
        create_file content_dir/'tails.png'
        create_file content_dir/'banane.poem'
        torrent
      end
    end

    context "with multiple files" do
      let(:move) { build :move, torrent: multiple, target_directory: target_directory }

      it "should move files" do
        move # mention to trigger magic
        content_dir.should exist_as_directory
        (content_dir/'tails.png').should exist_as_file
        (content_dir/'banane.poem').should exist_as_file
        move.work!
        (content_dir/'tails.png').should_not exist_as_file
        (content_dir/'banane.poem').should_not exist_as_file
        (target_directory.full_path/'content').should exist_as_directory
        (target_directory.full_path/'content'/'tails.png').should exist_as_file
        (target_directory.full_path/'content'/'banane.poem').should exist_as_file
      end

      it "should remove old directory" do
        move.work!
        (source.full_path/'content').should_not exist_as_directory
      end

      it "should set target_directory directory" do
        move.work!
        multiple.content_directory.should == target_directory
        multiple.should be_persisted
        multiple.changes.should be_empty
      end

      it "should stop running torrent" do
        multiple.should_receive(:stop)
        move.work!
      end

    end

  end

  it "should log errors to somewhere"
  it "should rsync, rm content between different partitions"

end

describe Move, 'auto targeting' do
  before :each do
    @red   = create :directory, name: 'Red'
    @green = create :directory, name: 'Green'
    @blue  = create :directory, relative_path: 'directory/with/blue'
  end

  it { @red.should be_auto_targeted_by(title: "Hunt for red October") }
  it { @blue.should be_auto_targeted_by(title: "Blueberry Nights") }
  it { @blue.should be_auto_targeted_by(filename: 'the blues brothers.torrent') }
end

describe Move, 'target' do
  it "moves the torrent's payload to the final directory" do
    torrent = double('Torrent', payload: stub('payload', multiple?: false, path: 'content_dir'),
                                stop: true, save!: true, 'content_directory=' => true )

    move = Move.new
    move.stub(:torrent).and_return(torrent)
    move.stub(:final_directory).and_return(stub('dir', full_path: 'final_dir'))

    FileUtils.should_receive(:mv).with('content_dir', 'final_dir')
    move.work!
  end

  let(:source) { create :directory }
  let(:disk) { nil }
  let(:directory) { nil }
  let(:move) { build :move, target_disk: disk, target_directory: directory, torrent: torrent }
  let(:torrent) do
    build :torrent_with_picture_of_tails, content_directory: source
  end

  describe "only disk given" do
    let(:disk) { create :disk }
    it "should move to same directory on other disk" do
      move.final_directory.full_path.should == disk.path/source.relative_path
    end
  end

  describe "only directory given" do
    let(:directory) { create :directory }
    it "should move within the disk" do
      move.final_directory.full_path.should == source.disk.path/directory.relative_path
    end
  end

  describe "directory given existing on given disk" do
    let(:directory) { create :directory }
    let(:disk) { directory.disk }
    before :each do
      create_directory directory.full_path
    end
    it "just moves it there" do
      move.final_directory.should == directory
    end
  end

  describe "directory given not existing on given disk" do
    let(:directory) { create :directory }
    let(:disk) { create :disk }
    it "creates a new directory on target disk" do
      move.final_directory.should be_present
      move.final_directory.full_path.should == disk.path/directory.relative_path
      move.final_directory.disk.should == disk
    end
  end

  describe "NESTED directory given, has copies on other disks" do
    let(:disk1) { create :disk, name: "Disk 1" }
    let(:disk2) { create :disk, name: "Disk 2" }
    let(:series1) { create :directory, disk: disk1, relative_path: 'Serien' }
    let(:series2) { create :directory, disk: disk2, relative_path: 'Serien' }
    let(:existing) { create :directory, parent: series2, disk: disk2 }

    let(:source) {   create :directory, disk: disk1 }
    let(:torrent) {  create :torrent, content_directory: source }
    let(:move) { build :move, target_disk: disk1, target_directory: existing, torrent: torrent }

    let(:final) { move.final_directory }

    context "creating copy" do
      before { final }

      it "does not touch disk of existing directory" do
        existing.disk.should == disk2
      end
    end

    context "created copy" do
      it "reconstructs relative paths" do
        final.relative_path.should == existing.relative_path
      end

      it "does not use existing path" do
        final.full_path.should_not == existing.path
      end

      it "reconstructs nesting" do
        final.parent.should_not be_nil
        final.parent.disk.should == disk1
      end

      it "is on specified disk" do
        final.disk.should == disk1
      end

      it "should not use existing disk" do
        final.disk.should_not == existing.disk
      end
    end


  end

end
