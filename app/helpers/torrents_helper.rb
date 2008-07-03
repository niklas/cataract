module TorrentsHelper

  def torrent_menu_links
    [
      link_to('New', torrents_url),
      link_to('Running', search_torrents_url),
      link_to('Paused', search_torrents_url(:status => 'paused')),
      link_to('Watchlist', watched_torrents_url),
    ]
  end

  def progress_bar(torrent, label=nil)
    p = torrent.percent.to_i
    label ||= "#{p.to_s} (#{torrent.statusmsg})"
    content_tag('div', "#{p.to_s}%",
      {:class => 'percent_bar', :style => "width: #{p}%", :title => label})
  end

  def progress_image_for(torrent)
    p = torrent.progress.to_i
    content_tag('span',
      if torrent.running?
        sparkline_tag [p], 
          :type => :pie, 
          :remain_color => '#222222',
          :share_color => 'lightgrey',
          :background_color => 'none',
          :diameter => 32
      else
        image_tag('no_progress.png')
      end,
      {:class => 'progress', :id => "progress_#{torrent.id}", 
        :title => "#{p}%"}
    )
  end

  def transfer(torrent)
    if torrent.running?
      human_transfer(torrent.rate_down) + '/s - ' +  human_transfer(torrent.rate_up) + '/s'
    else
      'stalled'
    end
  end

  def actions_for_torrent(t)
    returning [] do |a|
      a << link_to_remote('start', :url => torrent_transfer_path(t), :method => :post) if t.startable?
      a << link_to_remote('stop', :url => torrent_transfer_path(t), :method => :delete) if t.stoppable?
      a << link_to_remote('pause', :url => pause_torrent_transfer_path(t), :method => :put) if t.running?
      if t.local?
        a << link_to('Content', torrent_files_path(t))
        a << link_to('Move content', edit_torrent_files_path(t))
      end
      a << link_to_remote('fetch', :url => fetch_torrent_path(t), :method => :put) if t.remote?
      a << link_to_remote('Add', :url => torrents_url(:url => t.url), :method => :post) if t.new_record? and t.fetchable?
      a << toggle_watch_button(t) unless t.new_record?
    end
  end


  def toggle_watch_button(t)
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
    number_to_human_size(kb.kilobytes).sub(/ytes$/,'') +
      (rate ? '/s' : '')
  end

  def human_bytes(b)
    human_transfer(b/1024,false)
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
