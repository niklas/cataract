require File.dirname(__FILE__) + '/../spec_helper'

describe Directory do
  include FakeFS::SpecHelpers
  let(:path) { "/nyan/NYan/nyAN" }
  let(:pathname) { Pathname.new(path) }

  context "path" do
    it "should accept path as string and convert it to Pathname" do
      directory = create :directory, :path => path
      directory.reload
      directory.path.should be_a(Pathname)
      directory.path.should == pathname
    end
    it "serializes Pathname" do
      directory = create :directory, :path => pathname
      directory.path.should be_a(Pathname)
      directory.path.should == pathname
    end

    it "must be absolute" do
      directory = build :directory
      directory.path = 'tmp/lol'
      directory.should_not be_valid
    end

    it "cannot already exist in db" do
      create :directory, path: '/there/can/be/only/one'
      dir = build(:directory, path: '/there/can/be/only/one')
      dir.should_not be_valid
    end
  end

  context "autocreation" do
    it "should create on filesystem if asked for" do
      directory = Factory :directory, :path => path, :auto_create => true
      File.directory?(path).should be_true
    end
    it "should create on filesystem only if asked for" do
      directory = Factory :directory, :path => path
      File.directory?(path).should_not be_true
    end
  end

  context "Factory" do
    it "should put relative paths into rootfs" do
      directory = build :directory, path: 'foo/bar'
      directory.path.should == rootfs/'foo'/'bar'
    end
  end
end
