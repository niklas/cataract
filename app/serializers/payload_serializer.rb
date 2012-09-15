class PayloadSerializer < BaseSerializer
  include TorrentsHelper
  attributes :torrent_id, :filenames, :size

  def attributes
    super.tap do |hash|
      hash['directory_id'] = object.torrent.content_directory_id
      hash['human_size'] = number_to_human_size(object.size).sub(/ytes$/,'')
      hash['id'] = object.torrent_id # trick ember
    end
  end
end

