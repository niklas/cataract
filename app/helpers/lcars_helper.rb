module LcarsHelper

  def lcars_background(opts={})
    col = opts[:color]
    %Q{background: #{col} url(#{lcars_decoration_url opts}) top right no-repeat;}
  end


  def show(obj,name,opts={}, &block)
    label = opts[:label] || _(name.to_s.humanize)
    if block_given? || !obj.respond_to?(name)
      concat di_dt_dd(label, capture(&block), :class => name), block.binding
    else
      val = obj.send(name) rescue "unknow attr: #{obj.class}##{name}"
      case val
      when ActiveRecord::Base
        val = render(:partial => "/#{val.table_name}/attribute", :object => val)
      when Array
        val = list_of(val)
      when Time
        val = nice_date(val)
      end
      di_dt_dd(label, val, :class => name)
    end
  end

  def di_dt_dd(dt,dd, opts={})
    content_tag(:di,
                content_tag(:dt, dt) +
                content_tag(:dd, dd),
                opts
               )
  end

  def lcars_paginate(collection, opts={})
    will_paginate collection, opts.merge(
      :inner_window => 1, 
      :container => false,
      :renderer => 'LcarsPaginateLinkRenderer'
    )
  end
end

class LcarsPaginateLinkRenderer < WillPaginate::LinkRenderer
  def page_link_or_span(page, span_class, text = nil)
    @template.content_tag(:li, super)
  end
end
