require 'spec_helper'

describe Disk do
  it "needs a name" do
    build(:disk, name: nil).should be_invalid
  end

  it "needs a path" do
    build(:disk, path: nil).should be_invalid
  end
end
