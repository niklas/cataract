require 'spec_helper'

describe Disk do
  it "needs a name" do
    build(:disk, path: nil, name: '').should be_invalid
  end

  it "builds name from path if unnamed" do
    build(:disk, path: '/media/more', name: '').name.should == 'more'
  end

  it "does not build name from path if name present" do
    build(:disk, path: '/media/more').name.should_not == 'more'
  end

  it "needs a path" do
    build(:disk, path: nil).should be_invalid
  end

  it "needs the path to be absolute" do
    Disk.new( FactoryGirl.attributes_for(:disk, path: 'foo/var') ).should be_invalid
  end

  context "Factory" do
    it "should put relative paths into rootfs" do
      disk = build :disk, path: 'foo/bar'
      disk.path.should == rootfs/'foo'/'bar'
    end
  end

  context "find_or_create_root_directory_by_basename" do
    it "should find existing dir"
    it "should ignore non-root dirs"
    it "should create new dir"
  end
end
