module TagsHelper
  def tag_cloud(css_classes_count = 5)
    tags = Torrent.tag_counts
    count = tags.size
    min = tags.collect(&:count).min
    max = tags.collect(&:count).max
    span = (max-min).abs + 1
    class_size = span.to_f / css_classes_count
    tags.collect do |tag|
      class_num = 1 + (-1 + tag.count) / class_size.to_f
      inner = if block_given?
                yield tag.name
              else
                tag.name
              end
      content_tag('span',inner, { :class => sprintf("tag%02i", class_num)})
    end.join(' ')
  end

  def sidebar_switcher(divs=%w(watchlist tag_cloud))
    human_divs = divs.map(&:humanize).join(' / ')
    link_to_function human_divs, nil, {:id => 'sidebar_switcher'} do |page|
      page.toggle :watchlist
      page.toggle :tag_cloud
    end
  end
end
