module TorrentsHelper

  def torrent_menu_links
    [
      link_to('Recent', torrents_url),
      link_to('Running', torrents_url(:status => 'running')),
      link_to('Paused', torrents_url(:status => 'paused')),
      link_to('Watchlist', torrents_url(:only_watched => true)),
      link_to('New', new_torrent_url, :class => 'torrent')
    ]
  end

  def torrent_search
    returning '' do |html|
      html << form_tag(torrents_path,:method => :get, :id => 'torrent_search', :class => 'lcars_target_main')
      html << content_tag(:label,title_for_main, :for => 'term', :id => 'label_for_term')
      html << text_field_tag(:term, @term || '')
      html << hidden_field_tag(:only_watched, @only_watched)
      html << hidden_field_tag(:status, @status)
      html << hidden_field_tag(:_method, 'get')
      html << content_tag(:button, '➟', :title => 'Go', :type => 'submit')
      html << '</form>'
    end
  end

  def title_for_main
    if @only_watched
      'Your '
    else
      ''
    end + 
    if @status
      "#{@status} Torrents"
    elsif @term
      "Torrents containing '#{@term}'"
    else
      "Torrents"
    end
  end

  def progress_bar(torrent, label=nil)
    p = torrent.percent.to_i
    label ||= "#{p.to_s} (#{torrent.statusmsg})"
    content_tag('div', "#{p.to_s}%",
      {:class => 'percent_bar', :style => "width: #{p}%", :title => label})
  end

  def progress_image_for(torrent, opts={})
    begin
      if torrent.running? && progress = torrent.progress
        image_tag(sparkline_url(
          :type => :pie, 
          :results => progress,
          :remain_color => '#222222',
          :share_color => 'lightgrey',
          :background_color => 'none',
          :diameter => opts[:size] || 32
        ), :title => "#{progress}%", :alt => "#{progress}%", :class => 'progress')
      else
        no_progress_tag
      end
    rescue TorrentNotRunning, TorrentHasNoInfoHash
      no_progress_tag
    end
  end


  def no_progress_tag
    image_tag('no_progress.png', :class => 'progress')
  end

  def transfer(torrent)
    if torrent.running?
      human_transfer(torrent.rate_down) + '/s - ' +  human_transfer(torrent.rate_up) + '/s'
    else
      'stalled'
    end
  end

  def actions_for_torrent(t)
    render :partial => 'torrents/actions', :object => t
  end


  def toggle_watch_button(t)
    if watching = current_user.watches?(t)
      link_to_helm_remote "unwatch",
        :url => user_watching_url(current_user,watching),
        :method => :delete
    else
      link_to_helm_remote 'watch',
        :url => user_watchings_url(current_user, :torrent_id => t.id),
        :method => :post
    end
  end

  def fetch_torrent_form(torrent, opts={})
    opts_for_button = opts.delete(:button) || {}
    opts_for_button.merge!(:type => 'submit')
    opts_for_button[:title] = opts.delete(:title) if opts[:title]
    label = opts.delete(:label) || 'Fetch'
    opts[:class] = ResourcefulViews.resourceful_classnames('torrent', 'fetch', *(opts.delete(:class) || '').split)
    opts[:action] = fetch_torrent_path(torrent)
    content_tag('form', opts) do
      token_tag.to_s +
      hidden_field_tag('_method', 'put', :id => nil) +
      content_tag(:button, label, opts_for_button)
    end
  end

  def link_to_helm_remote(name, options = {}, html_options = {})
    link_to_remote(name,options,html_options.merge(:target => 'helm'))
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
end
