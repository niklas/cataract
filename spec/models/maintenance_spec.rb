require 'spec_helper'

describe Maintenance do
  it "should provide namespace for inheritorz" do
    Maintenance.should be_instance_of(Module)
  end

end

describe Maintenance::Base do
  it "should not be an abstract class" do
    described_class.should_not be_abstract_class
  end

  it "should have existing table" do
    described_class.should be_table_exists
  end
end
