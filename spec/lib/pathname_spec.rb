require 'spec_helper'

describe Pathname do
  let(:pathname) { described_class.new(path) }

  context "split_first" do

    context "on absolute paths" do
      let(:path) { '/a/b/c' }

      it "raises error" do
        lambda {
          path.split_first
        }.should raise_error
      end
    end


    context "on one-element paths" do
      let(:path) { 'c' }

      it "raises error" do
        lambda {
          path.split_first
        }.should raise_error
      end
    end


    context "on relative paths" do
      let(:path) { 'a/b/c' }
      subject { pathname.split_first }

      it "returns Array with two items" do
        subject.length.should == 2
      end
      it "extracts first element" do
        subject.first.should == 'a'
      end
      it "keeps the rest as relative pathname" do
        subject.last.should == Pathname.new('b/c')
      end
    end
  end
end
