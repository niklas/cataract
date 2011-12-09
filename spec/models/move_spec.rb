require 'spec_helper'

describe Move do

  it "should notify after create" do
    Move.should_receive(:notify).and_return(true)
    Factory :move
  end

end
