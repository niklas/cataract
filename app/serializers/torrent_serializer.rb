class TorrentSerializer < BaseSerializer
  # FIXME where should we provide keys for associations to Ember? content_directory or .._id?
  attributes :id,
             :title,
             :info_hash,
             :filename,
             :status,
             :content_directory_id,
             :updated_at,
             :payload_exists,
             :payload_bytes,
             :payload_id,
             :created_at

  def payload_id
    object.id
  end

  def payload_bytes
    if object.payload_exists?
      object.payload.size
    end
  end

end
