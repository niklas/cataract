require 'spec_helper'

describe Pathname do
  let(:pathname) { described_class.new(path) }

  context "relative_components" do

    context "on absolute paths" do
      let(:path) { '/a/b/c' }

      it "raises error" do
        lambda {
          pathname.relative_components
        }.should raise_error
      end
    end


    context "on one-element paths" do
      let(:path) { 'c' }

      it "wraps it in an array" do
        pathname.relative_components.should == ['c']
      end
    end


    context "on relative paths" do
      let(:path) { 'a/b/c' }
      subject { pathname.relative_components }

      it "has an item for each component" do
        subject.length.should == 3
      end
      it "has the items in the same order as efore" do
        should == %w(a b c)
      end
    end
  end
end
