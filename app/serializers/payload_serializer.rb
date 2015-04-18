class PayloadSerializer < BaseSerializer
  attributes :id,
             :torrent_id,
             :directory_id,
             :filenames,
             :size

  def id
    object.torrent_id # trick ember
  end

  def directory_id
    object.torrent.content_directory_id
  end
end

