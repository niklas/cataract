require File.dirname(__FILE__) + '/../spec_helper'

describe Directory do
  include FakeFS::SpecHelpers
  let(:path) { "/nyan/NYan/nyAN" }
  let(:pathname) { Pathname.new(path) }

  context "path" do
    it "should accept path as string and convert it to Pathname" do
      directory = Factory :directory, :path => path
      directory.reload
      directory.path.should be_a(Pathname)
      directory.path.should == pathname
    end
    it "serializes Pathname" do
      directory = Factory :directory, :path => pathname
      directory.path.should be_a(Pathname)
      directory.path.should == pathname
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
end
