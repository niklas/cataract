# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def group_link(status)
    content_tag('li',
                link_to(status.capitalize, :controller => 'torrents', :action => 'list', :status => status),
                { :class => (@status == status ? 'active' : '')}
    )
  end
end
