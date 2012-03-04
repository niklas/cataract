require 'spec_helper'
require 'mlocate'

describe Mlocate do

  it "should locate files" do
    found = Mlocate.file('sh')
    found.should_not be_nil
    found.should_not be_empty
    found.should include('/bin/sh')
  end

  it "should find postfix" do
    postfix = 'cats/tails.png'
    full    = "/usr/share/#{postfix}"
    Mlocate.stub(:run).with(postfix).and_return([full])
    found = Mlocate.postfix(postfix)
    found.should_not be_nil
    found.should_not be_empty
    found.should include(full)
  end
end
