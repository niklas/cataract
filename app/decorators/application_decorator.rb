class ApplicationDecorator < Draper::Base
  def close_modal
    page.select('#modal .modal-body').modal('close')
  end

  def selector_for(name, resource=nil, *more)
    case name
    when :errors_for
      %Q~#{selector_for(:form_for, resource)} .errors~
    when :form_for
      if resource.to_key
        %Q~form##{h.dom_id resource, :edit}~
      else
        %Q~form##{h.dom_id resource}~
      end
    else
      begin
        super
      rescue NoMethodError => no_method
        raise ArgumentError, "cannot find selector for #{name}"
      end
    end
  end

  # select a specific element on the page. You may implement #selector_for in your subclass
  def select(*a)
    page.select selector_for(*a)
  end

  def remove(*a)
    select(*a).remove()
  end

  # Lazy Helpers
  #   PRO: Call Rails helpers without the h. proxy
  #        ex: number_to_currency(model.price)
  #   CON: Add a bazillion methods into your decorator's namespace
  #        and probably sacrifice performance/memory
  #  
  #   Enable them by uncommenting this line:
  #   lazy_helpers

  # Shared Decorations
  #   Consider defining shared methods common to all your models.
  #   
  #   Example: standardize the formatting of timestamps
  #
  #   def formatted_timestamp(time)
  #     h.content_tag :span, time.strftime("%a %m/%d/%y"), 
  #                   :class => 'timestamp' 
  #   end
  # 
  #   def created_at
  #     formatted_timestamp(model.created_at)
  #   end
  # 
  #   def updated_at
  #     formatted_timestamp(model.updated_at)
  #   end
end
