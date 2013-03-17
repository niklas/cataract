# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def settings
    @settings ||= Setting.singleton
  end
end
