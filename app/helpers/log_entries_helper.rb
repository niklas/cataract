module LogEntriesHelper
  def log_entry_tag(entry)
    content_tag( :li, entry.final_message, :class => "message #{entry.level}")
  end
end
