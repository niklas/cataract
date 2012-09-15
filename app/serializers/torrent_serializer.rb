class TorrentSerializer < BaseSerializer
  attributes :id, :title, :info_hash, :filename, :status

  def attributes
    super.tap do |hash|
      hash['human_content_size'] = number_to_human_size(object.content_size).sub(/ytes$/,'')
    end
  end
end
