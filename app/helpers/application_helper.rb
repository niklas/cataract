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
    d.to_s(:db)
  end

  def sidebar_switcher(divs=%w(watchlist tag_cloud))
    human_divs = divs.map(&:humanize).join(' / ')
    divs.map do |domid|
      if session[:sidebar] == domid 
        content_tag('span', domid.humanize)
      else
        link_to_remote domid.humanize, :url => { :action => 'switch_sidebar', :to => domid}
      end
    end.join(' ')
  end

  def sidebar_div(domid, &block)
    style = session[:sidebar] == domid ? '' : 'display: none'
    concat(%Q[<div id="#{domid}" style="#{style}">], block.binding)
    yield 
    concat(%Q[</div>], block.binding)
  end
end
