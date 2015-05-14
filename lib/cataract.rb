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
    transfer_adapter_class.new
  end
end
