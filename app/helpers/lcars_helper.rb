module LcarsHelper

  def lcars_decoration(opts={})
    %Q[<img variant="#{opts[:variant]}" class="#{opts[:variant]} #{opts[:kind]} #{opts[:class]} decoration" src="#{lcars_decoration_url(opts)}" />]
  end

  def lcars_decoration_url(opts={})
    url = { :controller => 'lcars', :action => 'decoration' }
    raise "no kind given" unless opts.has_key? :kind
    raise "no variant given" unless opts.has_key? :variant
    url_for url.merge(opts)
  end

  def lcars_background(opts={})
    col = opts[:color]
    %Q{background: #{col} url(#{lcars_decoration_url opts}) top right no-repeat;}
  end
end
