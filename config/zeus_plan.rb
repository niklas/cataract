require 'zeus/rails'

class CustomPlan < Zeus::Rails
  def test
    require 'factory_girl'
    FactoryGirl.reload
    super
  end
end

Zeus.plan = CustomPlan.new

