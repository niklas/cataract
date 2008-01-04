module TorrentsHelper
  def progress_bar(torrent, label=nil)
    p = torrent.percent.to_i
    label ||= "#{p.to_s} (#{torrent.statusmsg})"
    content_tag('div', "#{p.to_s}%",
      {:class => 'percent_bar', :style => "width: #{p}%", :title => label})
  end

  def progress(torrent)
    content_tag('span',
      if torrent.running?
        sparkline_tag [torrent.percent], 
          :type => :pie, 
          :remain_color => '#222222',
          :share_color => 'lightgrey',
          :background_color => 'none',
          :diameter => 16
      else
        torrent.statusmsg || 'finished'
      end,
      {:class => 'progress', :id => "progress_#{torrent.id}", 
        :title => "#{torrent.percent.to_i}%"}
    )
  end

  def transfer(torrent)
    if torrent.running?
      human_transfer(torrent.rate_down) + '/s - ' +  human_transfer(torrent.rate_up) + '/s'
    else
      'stalled'
    end
  end

  def action_buttons_for(t)
    case t.current_state
    when :running
      button(t,'stop') +
      button(t,'pause')
    when :archived
      button(t,'start')
    when :paused
      button(t,'start') +
      button(t,'stop')
    when :remote
      button(t,'fetch')
    when :missing
      'file missing'
    when :stopping
      activity_effect_content(t,"stopping")
    when :fetching
      activity_effect_content(t,"fetching")
    else
      "[WTF: status #{t.status}]"
    end +
    content_tag('li', watchbutton(t))
  end

  def button(t,action)
    content_tag('li',
      link_to_remote(
        action, 
        :url => {:action => action, :id => t.id, :controller => 'torrents' },
        :loading => activity_effect(t,action + 'ing'))
               )
  end

  def watchbutton(t)
    if watching = current_user.watches?(t)
      link_to_remote "unwatch",
        :url => watching_url(watching),
        :method => :delete
    else
      link_to_remote 'watch',
        :url => watchings_url(:torrent_id => t.id),
        :method => :post
    end
  end

  def human_transfer(kb, rate=true)
    return '' unless kb
    return '' unless kb.kind_of?(Numeric)
    human_size(kb.kilobytes).sub(/ytes$/,'') +
      (rate ? '/s' : '')
  end

  def torrent_table(headings,torrents)
    return unless torrents
    return if torrents.empty?
    content_tag('table', 
      content_tag('tr', headings.collect { |h| 
        content_tag('th', h)
      }.to_s ) +
      torrents.collect { |t| 
        even = !even
        content_tag('tr', yield(t).collect { |d| 
          content_tag('td', d )
        }.to_s, {:class => cycle("even", "odd"), :id => "torrent_#{t.id}" })
      }.to_s
    )
  end

  def details_remote_link(t,caption=nil)
    caption ||= image_tag("buttons/details")
    link_to_remote caption,
      :url => { :action => 'show', :id => t.id }
  end

  def nice_error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    "Bad #{object.class.to_s.humanize}: " +
    if object && !object.errors.empty?
      object.errors.full_messages.join(', ')
    else
      ""
    end
  end

  def short_error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    if object && !object.errors.empty?
      object.errors.full_messages.join(', ')
    else
      ""
    end
  end

  def link_to_content(torrent,label='content')
    if content_url = torrent.content_url(current_user)
      link_to label, content_url
    else
      ''
    end
  end

  def activity_effect(torrent,message=nil)
    what = activity_effect_content(torrent,message)
    "$('torrent_#{torrent.id}').getElementsByTagName('div')[0].innerHTML='#{what}'"
  end

  def activity_effect_content(torrent,message="loading")
    message + image_tag('spinner.gif', :class => 'spinner')
  end

  def shown?(torrent)
    session[:shown_torrents].include?(torrent.id)
  end

  def previewed?(torrent)
    session[:previewed_torrents].include?(torrent.id)
  end

  def viewed?(torrent)
    shown?(torrent) || previewed?(torrent)
  end
end
