module TorrentsHelper
  def progress_bar(torrent)
    p = torrent.percent.to_i
    label = "#{p.to_s}%&nbsp;(#{torrent.statusmsg})"
    content_tag('div',
               content_tag('div',
                          content_tag('span', label, {:class => 'percent'}),
                          {:class => 'percent_bar', :style => "width: #{p}%"}),
               {:class => 'percent_container'}
               )
  end

  def progress(torrent)
    if torrent.running?
      progress_bar(torrent)
    else
      torrent.statusmsg || 'finished'
    end
  end

  def transfer(torrent)
    if torrent.running?
      human_transfer(torrent.rate_down) + '/s - ' +  human_transfer(torrent.rate_up) + '/s'
    else
      'stalled'
    end
  end

  def action_buttons_for(t)
    case t.status
    when 'running'
      button(t,'stop') +
      button(t,'pause')
    when 'archived'
      button(t,'start')
    when 'paused'
      button(t,'start') +
      button(t,'stop')
    when 'missing'
      'file missing'
    else
      "[WTF: status #{t.status}]"
    end +
    watchbutton(t) +
    details_remote_link(t)
  end

  def button(t,action)
      link_to_remote(image_tag("buttons/#{action}"), :url => {:action => action, :id => t.id })
  end

  def watchbutton(t)
    link_to_remote image_tag('buttons/watch'),
      :url => { :action => 'watch', :id => t.id},
      :update => { :success => 'watchlist'}
  end

  def human_transfer(kb)
    return 0 unless kb
    return 0 unless kb.kind_of?(Numeric)
    human_size(kb.kilobytes)
  end

  def torrent_table(headings,torrents)
    if torrents and !torrents.empty?
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
    else
      content_tag('p', "no torrents for #{@active_group}")
    end
  end

  def details_remote_link(t,caption=nil)
    caption ||= image_tag("buttons/details")
    link_to_remote caption,
      :url => { :action => 'show', :id => t.id }
  end

  def nice_error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    "Bad #{object_name.to_s.gsub("_", " ")}: " +
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
end
