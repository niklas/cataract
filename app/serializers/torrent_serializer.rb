class TorrentSerializer < BaseSerializer
  # FIXME where should we provide keys for associations to Ember? content_directory or .._id?
  attributes :id, :title, :info_hash, :filename, :status, :content_directory_id

  def attributes
    super.tap do |hash|
      hash['payload_exists'] = object.payload.exists?
      #hash['payload_id'] = object.payload.exist?? object.id : nil
      #hash['transfer_id'] = object.running?? object.id : nil
      # hash['transfers'] = [object.id] # ember-data cannot associate 1to1 currently, set always so it does not trigger an update
      # hash['payload'] = [object.id]
    end
  end

end
