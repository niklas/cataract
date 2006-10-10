# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def group_link(action)
    content_tag('li',
                link_to(action.capitalize, :action => action, :controller => 'torrents'),
                { :class => (@controller.action_name == action ? 'active' : '')}
    )
  end
end
