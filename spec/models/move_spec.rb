require 'spec_helper'

RSpec::Matchers.define :exist_as_directory do
  match { |actual| File.directory?(actual.to_s) }
end
RSpec::Matchers.define :exist_as_file do
  match { |actual| File.file?(actual.to_s) }
end

describe Move do
  include FactoryGirl::Syntax::Default

  it "be marked as acting like queuable" do
    Move.new.should be_acts_like(:queueable)
  end

  it "should extract paths from torrent and target"

  let(:file_factory) { Rails.root/'spec'/'factories'/'files' }

  context "in filesystem" do
    let(:rootfs)   { Rails.root/'tmp'/'rootfs' }
    let(:incoming) { rootfs/'incoming' }
    let(:archive)  { rootfs/'archive' }
    def create_file(path)
      FileUtils.copy file_factory/path.basename, path
    end

    after          { FileUtils.rm_rf(rootfs) if rootfs.exist? }

    let(:source)   { Factory :existing_directory, path: incoming }
    let(:target)   { Factory :existing_directory, path: archive }

    it "has directoy structure to work on" do
      source.should be_persisted
      target.should be_persisted
      incoming.should exist_as_directory
      archive.should  exist_as_directory
    end

    let(:single) do
      build :torrent_with_content do |torrent|
        torrent.stub content_path: incoming/'file.png', directory: source
        create_file torrent.content_path
        torrent
      end
    end

    it "should move single file" do
      move = build :move, torrent: single, target: target
      (incoming/'file.png').should exist_as_file
      move.torrent.should be_present
      move.work!
      (incoming/'file.png').should_not exist_as_file
      (archive/'file.png').should exist_as_file
    end

  end

  it "should move content of a multiple-file torrent"
  it "should move content within the same partition"
  it "should rsync, rm content between different partitions"
  it "should log errors to somewhere"

end
