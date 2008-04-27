module NotificationHelper
  def notification_tag(message, html_opts = {})
    html_opts[:style] = "display: none"
    content_tag( 'div', message, html_opts)
  end

  def notification(message, css_class = '')
    domid = "notice_" + (rand*5000000).to_i.to_s
    page.insert_html :bottom, :notice, page.context.notification_tag(message, {:id => domid})
    page.visual_effect :fade, domid, {
      :queue => {:position => 'end', :scope => 'notice' }, 
      :delay => 3, 
      :duration => 1.5,
      :afterFinish => "function() { noticeWillBeRemoved(); $('#{domid}').remove() }"
    }
    page.visual_effect :blind_down, domid, {
      :queue => {:position => 'front', :scope => 'notice' }, 
      :duration => 0.5,
      :afterFinish => "noticeWasInserted"
    }
  end

  # FIXME this is not DRY. wait for Hobo to solidate
  def log_entry_tag(entry)
    %Q[<li class="#{entry.level}">#{entry.message}</li>]
  end
  def append_log_to(page)
    if @logs
      @logs << LogEntry.new(flash[:notice], :notice) unless flash[:notice].blank?
      @logs << LogEntry.new(flash[:error], :error)   unless flash[:error].blank?
      @logs << LogEntry.new(flash[:message], :info)  unless flash[:info].blank?
      @logs.each do |le| 
        page.insert_html :bottom, 'event_log', log_entry_tag(le)
      end
    end
  end

  def render_pending_notifications
    pc =  page.context
    notification(pc.flash[:notice]) unless pc.flash[:notice].blank?
    mess = pc.flash[:messages]
    mess.each do |m| 
      notification(m)
    end if (mess && !mess.empty?)
    notification(pc.flash[:error], {:class => 'error'}) unless pc.flash[:error].blank?
    pc.flash.discard
  end
end
