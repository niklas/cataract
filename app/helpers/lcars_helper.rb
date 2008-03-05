module LcarsHelper

  def lcars_background(opts={})
    col = opts[:color]
    %Q{background: #{col} url(#{lcars_decoration_url opts}) top right no-repeat;}
  end
end
