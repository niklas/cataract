module Cataract
  autoload :TitleFinder, 'cataract/title_finder'

  def self.title_finder
    @title_finder ||= TitleFinder.new.method(:find_title)
  end

  def self.debrander
    @debrander ||= Cataract::FileNameCleaner.method(:clean)
  end
end
