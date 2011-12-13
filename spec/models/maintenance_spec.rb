require 'spec_helper'

describe Maintenance do
  it "should be an abstract class for all other maintenances" do
    Maintenance.should be_abstract_class
  end
end
