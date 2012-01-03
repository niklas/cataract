class Maintenance::ContentDirectoryAssigner < Maintenance::Base

  def work
    Torrent.where(:content_directory_id => nil).where('content_path IS NOT NULL').each do |torrent|
      dir, infix = directory_with_minimal_infix(torrent)
      if dir
        torrent.content_directory = dir
        torrent.content_path_infix = infix.to_s
        torrent.content_path = nil
        torrent.save!
      else
        STDERR.puts "no directory found for #{torrent.read_attribute(:content_path)}"
      end
    end
  end

  # DOH if we would have used Pathname#include? no content_path_infices with .. would have been created
  #     but there also was a confusion about the union-fs, we will fix this later
  def undo_doubledots
    Torrent.where("content_path_infix LIKE '..%'").includes(:content_directory).each do |t| 
      torrent.update_attributes! content_directory_id: nil, 
                                 content_path_infix: nil, 
                                 content_path: (torrent.content_directory.path/t.content_path_infix).to_s.sub(/more\d/,'all')
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

