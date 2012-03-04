module NavigationHelper
  # renders a link (a) within a list item (li),
  # uses cancan to optionally hide it and
  # activates it if the current path matches 
  #   a) the provided path or
  #   b) the given regex (TODO)
  #
  #     li_link '.dashboard', dashboard_path, can: [:dashboard, current_user]
  def li_link(name, path, options = {})
    can = options.delete(:can)
    if !can || can?(*can)
      active = request.path.starts_with?( path )
      content_tag :li, class: active && 'active' do
        link_to name, path, options
      end
    end
  end
end
