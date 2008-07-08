module LogEntriesHelper
  def log_entry_tag(entry)
    content_tag( 
      :li,
      content_tag(:span, nice_date(entry.created_at, 'now'), :class => 'timestamp') +
      content_tag(:span, entry.final_message, :class => 'message'),
      :class => entry.level
    )
  end
end
