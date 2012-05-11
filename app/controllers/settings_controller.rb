class SettingsController < InheritedResources::Base
  load_and_authorize_resource

  def resource
    @setting ||= Setting.singleton
  end

  def create
    create! { settings_path }
  end

  def update
    update! { settings_path }
  end
end
