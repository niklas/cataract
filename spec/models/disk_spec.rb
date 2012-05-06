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
end
