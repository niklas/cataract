# TODO migrate to scss
class StylesheetsController < ApplicationController
  before_filter :set_headers
  skip_before_filter :login_from_cookie
  skip_before_filter :login_required
  before_filter :set_theme
  before_filter :set_default_theme
  after_filter  { |c| c.cache_page }
  layout nil

  private
  def set_headers
    ::ActionController::Base.page_cache_extension = '.css'
    headers['Content-Type'] = 'text/css; charset=utf-8'
  end

  def set_default_theme
    @default_theme_name = 'primary'
    @default_theme = @lcars_colors[@default_theme_name]
  end

  def set_theme
   @lcars_colors = {
     'primary' =>
     {   :Name => 'primary',
         :base => '#000000',
         :text => '#FFFFFF',
         :elbows => '#F1DF6F',
         :offline => '#FF0000',
         :offline_off => '#330000',
         :unavailable => '#3399FF',
         :primary => '#99CCFF',
         :color1 => '#FFFF33',
         :color2 => '#FFFFCC',
         :change => '#66FF33',
         :warning => '#FF3333',
         :input => '#111100'
      },
     'secondary' =>
     {   :Name => 'secondary',
         :base => '#000000',
         :text => '#FFFFFF',
         :elbows => '#B1957A',
         :offline => '#FF0000',
         :offline_off => '#330000',
         :unavailable => '#5355DE',
         :primary => '#99CCFF',
         :color1 => '#FFCC00',
         :color2 => '#FFFF99',
         :change => '#66FF33',
         :warning => '#FF3333',
         :input => '#111100'
      },
     'ancillary' =>
     {   :Name => 'ancillary',
         :base => '#000000',
         :text => '#FFFFFF',
         :elbows => '#F1B1AF',
         :offline => '#FF0000',
         :offline_off => '#330000',
         :unavailable => '#A27FA5',
         :primary => '#ADACD8',
         :color1 => '#FFFF33',
         :color2 => '#E6B0D4',
         :change => '#66FF33',
         :warning => '#FF3333',
         :input => '#111100'
      },
     'database' =>
     {   :Name => 'database',
         :base => '#000000',
         :text => '#FFFFFF',
         :elbows => '#CC6666',
         :offline => '#FF0000',
         :offline_off => '#330000',
         :unavailable => '#CCCCFF',
         :primary => '#99CCFF',
         :color1 => '#FF9900',
         :color2 => '#99CCFF',
         :change => '#66FF33',
         :warning => '#FF3333',
         :input => '#111100'
      },
     'error' =>
     {   :Name => 'error',
         :base => '#000000',
         :text => '#FFFFFF',
         :elbows => '#FF0000',
         :offline => '#FF0000',
         :offline_off => '#330000',
         :unavailable => '#FF0000',
         :primary => '#FF0000',
         :color1 => '#FF0000',
         :color2 => '#FF0000',
         :input => '#111100',
         :change => '#66FF33',
         :warning => '#FF3333',
         :position => 500
      },
     'busy' =>
     {   :Name => 'busy',
         :base => '#000000',
         :text => '#FFFFFF',
         :elbows => '#666666',
         :offline => '#666666',
         :offline_off => '#666666',
         :unavailable => '#666666',
         :primary => '#666666',
         :color1 => '#555555',
         :color2 => '#777777',
         :input => '#666666',
         :change => '#66FF33',
         :warning => '#FF3333',
         :position => 100
      }
   }
  end
end

