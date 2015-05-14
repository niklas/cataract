module Cataract
  autoload :TitleFinder, 'cataract/title_finder'
  autoload :Publisher, 'cataract/publisher'
  autoload :Transfer,         'cataract/transfer'
  autoload :TransferAdapters, 'cataract/transfer_adapters'

  def self.title_finder
    @title_finder ||= TitleFinder.new.method(:find_title)
  end

  def self.debrander
    @debrander ||= Cataract::FileNameCleaner.method(:clean)
  end

  def self.transfer_adapter_class
    Cataract::TransferAdapters::RTorrentAdapter
  end

  def self.transfer_adapter
    transfer_adapter_class.new rtorrent_socket_path
  end

  def self.rtorrent_socket_path
    @rtorrent_socket_path ||=  Pathname.new(__FILE__)/'..'/'..'/'tmp'/'rtorrent.socket'
  end
end
