# collects the values considering the transfer of a torrent
class Cataract::Transfer < Struct.new(:torrent)
  @@serializable_attributes = []

  def self.serializable_attr_accessor(attr)
    @@serializable_attributes << attr
    attr_accessor attr
  end

  def torrent_id
    torrent.id
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

  def read_attribute_for_serialization(attr)
    unless attr.in?( @@serializable_attributes + [:torrent_id, :progress, :info_hash])
      raise ArgumentError, "cannot serialize #{attr}"
    else
      send(attr)
    end
  end

  # FIXME spaghetti
  def fetch!(fields=[])
    Torrent.remote.apply [torrent], fields
  end

  def update(attrs={})
    attrs.except(:hash).each do |attr, value|
      send("#{attr.to_s.sub(/\?$/,'')}=", value)
    end
  end

  def info_hash
    torrent.info_hash
  end

end

