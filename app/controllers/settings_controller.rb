class SettingsController < InheritedResources::Base
  load_and_authorize_resource
  respond_to :json
  before_action :set_scraping_url

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
      prms.first.tap do |given|
        given.delete(:id)
        given.delete(:bookmark_link) # every attr DS wants to write, too
      end
    end
  end

private
  def set_scraping_url
    resource.scraping_url = open_scraping_url(format: 'js')
  end
end
