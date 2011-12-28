class Maintenance::ContentDirectoryAssigner < Maintenance::Base

  def work
    Torrent.where(:content_directory_id => nil).each do |torrent|
      dir, infix = directory_with_minimal_infix(torrent)
      if dir
        torrent.content_directory = dir
        torrent.content_path_infix = infix.to_s
        torrent.content_path = nil
        torrent.save!
      end
    end
  end

  private
  def directory_with_minimal_infix(torrent)
    directories
      .map { |dir| [dir, 
                    Pathname.new( torrent.read_attribute(:content_path) )
                            .relative_path_from(dir.path)
                   ] rescue nil }
      .compact
      .sort_by { |dir, infix| infix.to_s.length }
      .first
  end

  def directories
    @directories ||= Directory.all
  end

end

class Pathname
  # FIXME this ignores path delimiters
  def include?(other)
    other.to_s.start_with?(self.to_s)
  end
end
