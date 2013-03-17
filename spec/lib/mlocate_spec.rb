require 'spec_helper'
require 'mlocate'

describe Mlocate do

  it "finds files" do
    Mlocate.file('sh').should include('/bin/sh')
  end

  it "finds by postfix" do
    postfix = 'cats/tails.png'
    full    = "/usr/share/#{postfix}"
    Mlocate.stub(:run).with(postfix).and_return([full])
    Mlocate.postfix(postfix).should include(full)
  end

  it "offers query interface for file" do
    query = stub
    result = stub
    Mlocate.stub(:file).with(query).and_return(result)
    Mlocate.locate(file: query).should == result
  end
end
