module NotificationHelper
  def notification_tag(message, html_opts = {})
    html_opts[:style] = "display: none"
    content_tag( 'div', message, html_opts)
  end

  def notification(message, css_class = '')
    domid = "notice_" + (rand*5000000).to_i.to_s
    page.insert_html :top, :notice, page.context.notification_tag(message, {:id => domid})
    page.visual_effect :blind_up, domid, {
      :queue => {:position => 'front', :scope => 'notice' }, 
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
