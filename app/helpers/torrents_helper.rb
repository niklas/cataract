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
    details_remote_link(t,'details')
  end

  def button(t,action)
      link_to_remote(image_tag(action), :url => {:action => action, :id => t.id })
  end

  def watchbutton(t)
    link_to_remote image_tag('watch'),
      :url => { :action => 'watch', :id => t.id},
      :update => { :success => 'watchlist'}
  end

  def human_transfer(kb)
    return 0 unless kb
    return 0 unless kb.kind_of?(Numeric)
    human_size(kb.kilobytes)
  end

  def torrent_table(headings,torrents)
    even = true
    if torrents and !torrents.empty?
      content_tag('table', 
        content_tag('tr', headings.collect { |h| 
          content_tag('th', h)
        }.to_s ) +
        torrents.collect { |t| 
          even = !even
          content_tag('tr', yield(t).collect { |d| 
            content_tag('td', d )
          }.to_s, {:class => even ? 'even_row' : 'odd_row', :id => "torrent_#{t.id}" })
        }.to_s
      )
    else
      content_tag('p', "no torrents for #{@active_group}")
    end
  end

  def details_remote_link(t,caption=nil)
    link_to_remote image_tag("details"),
      :update => 'torrent',
      :url => { :action => 'show', :id => t.id }
  end
end
