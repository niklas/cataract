class LcarsController < ApplicationController
  # renders and caches the round corners of the LCARS design

  def decoration
    send_data( Lcars.plot(params),
				 :disposition => 'inline',
				 :type => 'image/png',
				 :filename => "lcars_corner.png" )
  end
end
