module Cataract
  class TitleFinder
    SignificantFiles = /\.(mkv|mp4|avi|mpe?g)$/

    def find_title(torrent)
      debrand(torrent.filename) ||
      from_content(torrent.content_filenames) ||
      (torrent.url.present? && debrand(File.basename(torrent.url)) )   ||
      (torrent.persisted?? "Torrent ##{torrent.id}" : "new Torrent")
    end

  private

    def from_content(files)
      if files.present?
        if found = files.grep(SignificantFiles)
          clean = found.first.gsub(SignificantFiles, '')
          debrand(clean)
        end
      end
    end

    # * removes some 1337 comments about format/group in the filename
    # * cuts the .torrent extention
    # * tranforms interpunctuations into spaces
    # * kills renaming spaces 
    def debrand(name)
      Cataract.debrander[name]
    end
  end
end

