class TorrentSerializer < BaseSerializer
  attributes :id, :title, :info_hash, :status, :content_directory_id, :content_filenames, :content_size

  def attributes
    super.tap do |hash|
      hash['human_content_size'] = number_to_human_size(object.content_size).sub(/ytes$/,'')
    end
  end
end
