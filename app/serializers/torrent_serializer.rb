class TorrentSerializer < BaseSerializer
  # FIXME where should we provide keys for associations to Ember? content_directory or .._id?
  attributes :id, :title, :info_hash, :filename, :status, :content_directory_id

  def attributes
    super.tap do |hash|
      hash['payload_id'] = object.payload.exist?? object.id : nil
      hash['transfer_id'] = object.running?? object.id : nil
    end
  end

end
