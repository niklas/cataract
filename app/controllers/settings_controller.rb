class SettingsController < ApplicationController
  def index
    @settings = Settings.defaults.merge Settings.all
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page.replace_html 'main_content', :partial => 'list', :object => @settings
        end
      end
    end
  end
end
