require File.dirname(__FILE__) + '/../spec_helper'

describe Directory do
  include FakeFS::SpecHelpers
  context "autocreation" do
    let(:path) { "/nyan/NYan/nyAN" }
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
