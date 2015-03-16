module ControllerMacros
  def signin_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in create(:user)
  end
end

RSpec.configure do |config|
  config.include ControllerMacros, :type => :controller
end
