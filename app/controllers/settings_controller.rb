class SettingsController < InheritedResources::Base
  load_and_authorize_resource
  respond_to :json

  def resource
    @setting ||= Setting.singleton # ignore the param until we want multiple settings
  end

  def create
    create! { settings_path }
  end

  def update
    update! { settings_path }
  end
end
