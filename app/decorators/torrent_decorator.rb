class TorrentDecorator < ApplicationDecorator
  decorates :torrent

  allows :running?, :content

  def progress
    handle_remote do
      h.content_tag(:div, '', class: 'stretcher') +
      h.render('pie', percent: torrent.progress)
    end
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

  def directory
    val :directory, class: 'dir' do
      render_directory model.directory
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
  end

  def link_to_clear
    h.link_to h.ti(:clear), h.torrent_content_path(torrent), :method => :delete, class: 'clear btn btn-danger', confirm: "really?"
  end

  def error(kind)
    h.content_tag :span, kind, class: "#{kind} error"
  end

  def render_directory(dir)
    h.content_tag(:span, dir.name, class: 'name') +
    h.content_tag(:span, dir.path, class: 'path')
  end

  def selector_for(name, resource=nil, *more)
    case name
    when :progress
      "##{item_id} .progress"
    else
      super
    end
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
