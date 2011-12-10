require 'spec_helper'

RSpec::Matchers.define :exist_as_directory do
  match do |actual|
    File.exist?(actual.to_s)
  end
end

describe Move do

  it "be marked as acting like queuable" do
    Move.new.should be_acts_like(:queueable)
  end

  context "in filesystem" do
    let(:rootfs)   { Rails.root/'tmp'/'rootfs' }
    after          { FileUtils.rm_rf(rootfs) if rootfs.exist? }

    let(:incoming) { Factory :existing_directory, path: rootfs/'incoming' }
    let(:archive)  { Factory :existing_directory, path: rootfs/'archive' }
    let(:single)   { Factory :torrent_with_single_file, directory: incoming }

    it "has directoy structure to work on" do
      incoming.path.should exist_as_directory
      archive.path.should  exist_as_directory
    end

    it "should move content of a single-file torrent" do
      pending
      move = Factory :move, torrent: single, target: archive
    end

  end
  it "should move content of a multiple-file torrent"
  it "should move content within the same partition"
  it "should rsync, rm content between different partitions"
  it "should log errors to somewhere"

end
