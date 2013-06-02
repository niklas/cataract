class SettingsController < InheritedResources::Base
  load_and_authorize_resource
  respond_to :json

  def resource
    @setting ||= Setting.singleton # ignore the param until we want multiple settings
  end

  # must provide id for emu, so each save is an update
  def update
    update! do |success|
     success.json {  render json: resource, serializer: SettingSerializer }
    end
  end

  def resource_params
    super.tap do |prms|
      prms.first.delete(:id)
    end
  end
end
