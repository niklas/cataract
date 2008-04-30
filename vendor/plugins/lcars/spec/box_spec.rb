require 'init'
describe LcarsBox do
  before(:each) do
    @box = LcarsBox
  end
  it "should be a class" do
    @box.should be_instance_of(Class)
  end
end
