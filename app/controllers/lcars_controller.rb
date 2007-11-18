class LcarsController < ApplicationController
  skip_before_filter :login_from_cookie
  skip_before_filter :login_required
  # renders and caches the round corners of the LCARS design

  def decoration
    send_data( Lcars.plot(params),
				 :disposition => 'inline',
				 :type => 'image/png',
				 :filename => "lcars_corner.png" )
  end
end
