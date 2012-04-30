require 'spec_helper'

describe Disk do
  it "needs a name" do
    build(:disk, name: '').should be_invalid
  end

  it "needs a path" do
    pending "conflict with serialize"
    build(:disk, path: nil).should be_invalid
  end
end
