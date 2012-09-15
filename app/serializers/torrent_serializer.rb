class TorrentSerializer < BaseSerializer
  attributes :id, :title, :info_hash, :filename, :status

  def attributes
    super.tap do |hash|
      hash['payload_id'] = object.payload.exist?? object.id : nil
    end
  end

end
