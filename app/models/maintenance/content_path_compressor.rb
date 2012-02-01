class Maintenance::ContentPathCompressor < Maintenance::Base

  def work
    Torrent.where('content_path_infix IS NOT NULL').where('(status IS NULL OR status != ?)', 'missing').each do |t|
      infix = t.content_path_infix
      if t.content_filenames.first.start_with?(infix)
        path = t.content_directory.path
        full = path/infix
        unless full.exist?
          missing! t
          next
        end
        tmp = path/"torrent_#{t.id}_content"

        if full.directory?
          File.rename full, tmp
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

  private
  def missing!(torrent)
    logger.info "Torrent(#{torrent.id})#content_path '#{torrent.content_path}' does not exist, cannot compress"
    torrent.status = :missing
    torrent.content_path = nil
    torrent.content_path_infix = nil
    torrent.save!
  end

end
