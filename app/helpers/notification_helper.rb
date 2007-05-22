module NotificationHelper
  def notification_tag(message, html_opts = {})
    html_opts[:style] = "display: none"
    content_tag( 'div', message, html_opts)
  end

  def notification(message, css_class = '')
    domid = "notice_" + (rand*5000000).to_i.to_s
    update_page do |page|
      page.insert_html :top, :notice, notification_tag(message, {:id => domid})
      page.visual_effect :blind_down, domid, {
        :queue => {:position => 'end', :scope => 'notice_open' }, 
        :duration => 0.5
      }
      page.visual_effect :blind_up, domid, {
        :queue => {:position => 'end', :scope => 'notice_close' }, 
        :delay => 3, 
        :duration => 1.5
      }
    end
  end

  def js_reset_notifications
    <<EOJS
      var queue = Effect.Queues.get('notice_close');
      queue.each(function(e) { 
          if (e.element == $('notice')) {
            e.cancel();
          }
      })
      queue = Effect.Queues.get('notice_open');
      queue.each(function(e) { 
          if (e.element == $('notice')) {
            e.cancel();
          }
      })
EOJS
  end

  def js_notification_begin
    js_reset_notifications + 
    visual_effect(:appear, :notice, { 
      :queue => {:position => 'front', :scope => 'notice_open' }, 
      :from => "$('notice').style.opacity", :to => 0.4
    })
  end

  def js_notification_end
    visual_effect(:fade, :notice, { 
      :queue => {:position => 'end', :scope => 'notice_close' }, 
      :from => 0.4, :to => 0,
      :duration => 2.3,
      :afterFinish => "function() { $('notice').update('') }"
    })
  end

  def render_pending_notifications
    js = ''
    js << js_notification_begin
    js << notification(flash[:notice]) unless flash[:notice].blank?
    js << @messages.collect { |m| notification(m) }.join(';') if @messages && !@messages.empty?
    js << notification(flash[:error], {:class => 'error'}) unless flash[:error].blank?
    js << js_notification_end
  end
end
