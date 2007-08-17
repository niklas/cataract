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

  # toggle the given tag for the search criteria
  def toggle_tag_link(tag)
    tag = tag.name if tag.is_a?(Tag)
    return content_tag('span',tag) unless @searched_tags
    if @searched_tags.include?(tag)
      remove_tag_link(tag)
    else
      add_tag_link(tag)
    end
  end

    # a link that adds the tag to the search
  def add_tag_link(label, tags = [])
    tags = [tags] unless tags.is_a?(Array)
    tags = [label] if tags.empty?
    modified_link(label, {:tags => (@searched_tags.to_a + tags).join(',') }, 
                         {:class => 'add', :title => "add '#{label}' to search"})
  end

  # a link that removes the tag from the search
  def remove_tag_link(label, tags = [])
    tags = [label] if tags.empty?
    modified_link(label, {:tags => (@searched_tags.to_a - tags).join(',') }, 
                         {:class => 'remove', :title => "remove '#{label}' from search"})
  end

  def modified_link(label, opts = {}, html_opts = {})
    opts[:action] = 'search'
    opts[:commit] = nil
    opts[:status] = nil
    link_to label, url_for(:overwrite_params => opts), html_opts
  end
end
