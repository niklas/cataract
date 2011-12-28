class TorrentDecorator < ApplicationDecorator
  decorates :torrent

  allows :running?

  def progress
    h.render 'pie', percent: torrent.progress
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
    human_bytes(bytes) + '/s'
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

  def error(kind)
    h.content_tag :span, kind, class: kind
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
