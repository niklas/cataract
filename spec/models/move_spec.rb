require 'spec_helper'

describe Move do
  it "be marked as acting like queuable" do
    Move.new.should be_acts_like(:queueable)
  end

  context "in filesystem" do
    let(:incoming) { rootfs/'incoming' }
    let(:archive)  { rootfs/'archive' }

    let(:source)   { Factory :existing_directory, path: incoming }
    let(:target)   { Factory :existing_directory, path: archive }

    it "has directoy structure to work on" do
      source.should be_persisted
      source.path.should exist_as_directory
      source.path.should == incoming
      target.should be_persisted
      target.path.should  exist_as_directory
      target.path.should == archive
    end

    let(:single) do
      build :torrent_with_picture_of_tails, content_directory: source, directory: source do |torrent|
        create_file incoming/'tails.png'
        torrent
      end
    end

    it "should move single file" do
      move = build :move, torrent: single, target: target
      (incoming/'tails.png').should exist_as_file
      move.work!
      (incoming/'tails.png').should_not exist_as_file
      (archive/'tails.png').should exist_as_file
      single.content_directory.should == target
      single.should be_persisted
      single.changes.should be_empty
    end

    let(:content_dir) { incoming/'content' } # directory name from torrent itself

    let(:multiple) do
      build :torrent_with_picture_of_tails_and_a_poem, content_directory: source, directory: source do |torrent|
        create_directory content_dir
        create_file content_dir/'tails.png'
        create_file content_dir/'banane.poem'
        torrent
      end
    end

    context "with multiple files" do
      let(:move) { build :move, torrent: multiple, target: target }

      it "should move files" do
        move # mention to trigger magic
        content_dir.should exist_as_directory
        (content_dir/'tails.png').should exist_as_file
        (content_dir/'banane.poem').should exist_as_file
        move.work!
        (content_dir/'tails.png').should_not exist_as_file
        (content_dir/'banane.poem').should_not exist_as_file
        (archive/'content').should exist_as_directory
        (archive/'content'/'tails.png').should exist_as_file
        (archive/'content'/'banane.poem').should exist_as_file
      end

      it "should remove old directory" do
        move.work!
        (incoming/'content').should_not exist_as_directory
      end

      it "should set target directory" do
        move.work!
        multiple.content_directory.should == target
        multiple.should be_persisted
        multiple.changes.should be_empty
      end

    end

  end

  it "should move content within the same partition"
  it "should rsync, rm content between different partitions"
  it "should log errors to somewhere"

  describe 'auto targeting' do
    before :each do
      @red   = create :directory, name: 'Red'
      @green = create :directory, name: 'Green'
      @blue  = create :directory, path: '/directory/with/blue'
    end

    it { @red.should be_auto_targeted_by(title: "Hunt for red October") }
    it { @blue.should be_auto_targeted_by(title: "Blueberry Nights") }
    it { @blue.should be_auto_targeted_by(filename: 'the blues brothers.torrent') }
  end
end
