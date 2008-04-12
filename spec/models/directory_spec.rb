require File.dirname(__FILE__) + '/../spec_helper'

describe Directory do
  before(:each) do
    @directory = Directory.new
  end

  it "should be valid" do
    @directory.should be_valid
  end
end
