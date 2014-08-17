class TorrentSerializer < BaseSerializer
  # FIXME where should we provide keys for associations to Ember? content_directory or .._id?
  attributes :id, :title, :info_hash, :filename, :status, :content_directory_id, :created_at

  def attributes
    super.tap do |hash|
      if object.payload.exists?
        hash['payload_exists'] = true
        hash['payload_kilo_bytes'] = object.payload.size / 1000
      end
      hash['payload_id'] = object.id
      #hash['transfer_id'] = object.running?? object.id : nil
      # hash['transfers'] = [object.id] # ember-data cannot associate 1to1 currently, set always so it does not trigger an update
      # hash['payload'] = [object.id]
    end
  end

end
