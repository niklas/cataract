# collects the values considering the transfer of a torrent
class Cataract::Transfer
  include ActiveModel::Model
  include ActiveModel::Serialization
  attr_accessor :info_hash,
                :torrent_id,
                :completed_bytes,
                :size_bytes,
                :up_rate,
                :down_rate

  @@serializable_attributes = []

  def self.serializable_attr_accessor(attr)
    @@serializable_attributes << attr
    #attr_accessor attr
  end

  def progress
    (100.0 * completed_bytes.to_f / size_bytes.to_f).to_i
  rescue FloatDomainError
    0
  end

  def arrived?
    completed_bytes == size_bytes
  end

  def left_seconds
    left_bytes.to_f / down_rate.to_f
  end

  def left_bytes
    size_bytes.to_i - completed_bytes.to_i
  end

  def XXXread_attribute_for_serialization(attr)
    unless attr.in?( @@serializable_attributes + [:torrent_id, :progress, :info_hash])
      raise ArgumentError, "cannot serialize #{attr}"
    else
      send(attr)
    end
  end

  # FIXME spaghetti
  def fetch!(fields=[])
    Cataract.transfer_adapter.apply [self], fields
  end

  def update(attrs={})
    attrs.except(:hash).each do |attr, value|
      public_send("#{attr.to_s.sub(/\?$/,'')}=", value)
    end
  end

end

