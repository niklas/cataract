class User::RegistrationsController < Devise::RegistrationsController

  before_filter :signup_disabled

  def signup_disabled
    authorize! :create, User
  end

end
