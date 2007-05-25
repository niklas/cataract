module NotificationHelper
  def notification_tag(message, html_opts = {})
    html_opts[:style] = "display: none"
    content_tag( 'div', message, html_opts)
  end

  def notification(message, css_class = '')
    domid = "notice_" + (rand*5000000).to_i.to_s
    update_page do |page|
      page.insert_html :top, :notice, notification_tag(message, {:id => domid})
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
  end

  def render_pending_notifications
    js = ''
    js << notification(flash[:notice]) unless flash[:notice].blank?
    js << @messages.collect { |m| notification(m) }.join(';') if @messages && !@messages.empty?
    js << notification(flash[:error], {:class => 'error'}) unless flash[:error].blank?
    js
  end
end
