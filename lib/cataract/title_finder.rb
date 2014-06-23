module Cataract
  class TitleFinder
    def find_title(torrent)
      debrand(torrent.filename) ||
      (torrent.url.present? && debrand(File.basename(torrent.url)) )   ||
      (torrent.persisted?? "Torrent ##{torrent.id}" : "new Torrent")
    end

    private
    # * removes some 1337 comments about format/group in the filename
    # * cuts the .torrent extention
    # * tranforms interpunctuations into spaces
    # * kills renaming spaces 
    def debrand(name)
      Cataract.debrander[name]
    end
  end
end

