class Maintenance::DirectoryAssigner < Maintenance::Base
  def work
    Torrent.where(:directory_id => nil).where('filename IS NOT NULL').each do |torrent|
      if dir = dir_containing_file(torrent.filename)
        torrent.directory = dir
        torrent.save!
      end
    end
  end

  private
  def directories
    @directories ||= Directory.all.select do |directory|
      directory.glob('*.torrent').present?
    end
  end

  def dir_containing_file(filename)
    directories.find { |dir| File.exist?(dir.path/filename) }
  end

end

