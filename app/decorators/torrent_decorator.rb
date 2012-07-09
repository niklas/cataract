class TorrentDecorator < ApplicationDecorator
  decorates :torrent

  allows :running?, :content, :moving?, :status, :title, :content, :active?, :previous_changes, :remote?, :url

  def progress
    h.render('bar', percent: percent, eta: eta)
  end

  def rates
    h.render('rates', up: up_rate, down: down_rate)
  end

  def update_progress
    select(:progress).width(percent) # is html if offline *shrug*
    select(:progress, '.percent').html(percent)
    select(:progress, '.eta').html(eta)
    select(:rates).html(rates)
  end

  def percent
    handle_remote do
      "#{torrent.progress}%"
    end
  end

  def eta
    handle_remote do
      now = Time.now
      h.distance_of_time_in_words(now, now + torrent.left_seconds)
    end
  rescue
    ''
  end

  def content_size
    human_bytes torrent.content_size
  end

  def up_rate
    handle_remote do
      human_bytes_rate torrent.up_rate
    end
  end

  def down_rate
    handle_remote do
      human_bytes_rate torrent.down_rate
    end
  end

  def message
    handle_remote do
      torrent.message
    end
  end

  def human_bytes(bytes)
    return if bytes.blank?
    h.number_to_human_size(bytes).sub(/ytes$/,'')
  end

  def human_bytes_rate(bytes)
    return if bytes.blank?
    human_bytes(bytes) + '/s'
  end

  def item_id
    "torrent_item_#{torrent.id}"
  end

  def transfer_id
    "transfer_torrent_#{torrent.id}"
  end

  def content_id
    "content_torrent_#{torrent.id}"
  end

  def filename
    val :filename do
      model.filename
    end
  end

  def content_directory
    val :content_directory, class: 'dir' do
      render_directory torrent.content_directory
    end
  end

  def series
    val :series do
      torrent.series.title
    end
  end


  def val(name, options = {}, &value)
    if model.send(name).present?
      val!(name, options, &value)
    end
  end

  def val!(name, options = {}, &value)
    h.content_tag(:di, options.merge(class: "#{name} #{options[:class]}")) do
      h.content_tag(:dt, Torrent.human_attribute_name(name) ) +
      h.content_tag(:dd, block_given?? value.call : model.send(name) )
    end
  end

  def handle_remote
    yield
  rescue Torrent::RTorrent::CouldNotFindInfoHash => e
    return error 'not running'
  rescue Torrent::RTorrent::Offline => e
    return error 'offline'
  rescue Errno::ECONNREFUSED => e
    return error 'unavailable'
  rescue Errno::ENOENT => e
    return error 'unavailable'
  end

  def link_to_clear
    h.link_to h.ti(:clear), h.torrent_content_path(torrent), :method => :delete, class: 'clear btn btn-danger', confirm: "really?", remote: true
  end

  def error(kind)
    h.content_tag :span, kind, class: "#{kind} error"
  end

  def render_directory(dir)
    h.content_tag(:span, h.link_to(dir.name, [dir.disk, dir]), class: 'name') +
    h.content_tag(:span, dir.path, class: 'path')
  end

  def selector_for(name, resource=nil, *more)
    case name
    when :progress
      "##{item_id} .progress .bar #{resource}"
    when :rates
      "##{item_id} .rates"
    when :item
      "##{item_id}"
    when :content
      'section.content'
    else
      super
    end
  end

  def prepend_to_list
    page['torrents'].prepend h.render('torrents/item', torrent: model)
    select(:item, model).effect('highlight', {}, 1000)
  end


  def update_in_list
    select(:item, model).replace_with h.render('torrents/item', torrent: model)
  end

  # Accessing Helpers
  #   You can access any helper via a proxy
  #
  #   Normal Usage: helpers.number_to_currency(2)
  #   Abbreviated : h.number_to_currency(2)
  #   
  #   Or, optionally enable "lazy helpers" by calling this method:
  #     lazy_helpers
  #   Then use the helpers with no proxy:
  #     number_to_currency(2)

  # Defining an Interface
  #   Control access to the wrapped subject's methods using one of the following:
  #
  #   To allow only the listed methods (whitelist):
  #     allows :method1, :method2
  #
  #   To allow everything except the listed methods (blacklist):
  #     denies :method1, :method2

  # Presentation Methods
  #   Define your own instance methods, even overriding accessors
  #   generated by ActiveRecord:
  #   
  #   def created_at
  #     h.content_tag :span, time.strftime("%a %m/%d/%y"), 
  #                   :class => 'timestamp'
  #   end
end
