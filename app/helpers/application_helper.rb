# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def group_link(status)
    content_tag('li',
                link_to(status.capitalize, :controller => 'torrents', :action => 'list', :status => status),
                { :class => (@status == status ? 'active' : '')}
    )
  end

  def all_stylesheets
    %w(layout style watchlist torrents forms corners).map do |style|
      stylesheet_link_tag style
    end
  end

  def context
    page.instance_variable_get("@context").instance_variable_get("@template")
  end

  def nice_date(d)
    d ? d.to_s(:db) : content_tag(:span,'unknown', :class => 'warning')
  end

  def number_to_human_rate(num=nil,precision=1)
    size = number_to_human_size(num,precision)
    size ? "#{size}/s" : size
  end

end
