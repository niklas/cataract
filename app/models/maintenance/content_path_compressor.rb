class Maintenance::ContentPathCompressor < Maintenance::Base

  def work
    Torrent.where('content_path_infix IS NOT NULL').each do |t|
      if t.content_filenames.first.start_with?(t.content_path_infix)
        path = t.content_directory.path
        unless path.exist?
          logger.info "Torrent(#{t.id})#content_path '#{path}' does not exist, cannot compress"
          next
        end
        tmp = path/"torrent_#{t.id}_content"

        File.rename path/t.content_path_infix, tmp
        tmp.children.each do |content|
          FileUtils.mv content, path
        end

        Dir.rmdir tmp

        t.content_path = nil
        t.content_path_infix = nil
        t.save!
      end
    end
  end

end
