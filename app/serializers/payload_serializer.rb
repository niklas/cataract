class PayloadSerializer < BaseSerializer
  attributes :torrent_id, :filenames, :size

  def attributes
    super.tap do |hash|
      hash['directory_id'] = object.torrent.content_directory_id
      hash['id'] = object.torrent_id # trick ember
    end
  end
end

