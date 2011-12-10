require 'spec_helper'

describe Move do

  it "be marked as acting like queuable" do
    Move.new.should be_acts_like(:queueable)
  end

end
