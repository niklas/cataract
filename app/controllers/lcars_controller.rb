class LcarsController < ApplicationController
  skip_before_filter :login_from_cookie
  skip_before_filter :login_required
  # renders and caches the round corners of the LCARS design

  caches_page :decoration

  def decoration
    data, key = Lcars::Decoration.plot(params) 
    filename = "#{key}.png"
    cache_page data, params # we'll if this works..
    send_data(data , 
				 :disposition => 'inline',
				 :type => 'image/png',
				 :filename => filename )
  end
end
