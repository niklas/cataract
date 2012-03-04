require 'spec_helper'
require 'mlocate'

describe Mlocate do

  it "should locate files" do
    found = Mlocate.file('sh')
    found.should_not be_nil
    found.should_not be_empty
    found.should include('/bin/sh')
  end
end
