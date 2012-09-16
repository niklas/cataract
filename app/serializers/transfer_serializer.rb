class TransferSerializer < BaseSerializer
  include TorrentsHelper
  attributes :torrent_id, :progress
  has_one :torrent

  def attributes
    super.tap do |hash|
      hash['up_rate'] = human_bytes_rate object.up_rate
      hash['down_rate'] = human_bytes_rate object.down_rate
      hash['eta'] = time_left_in_words object.left_seconds
      hash['id'] = object.torrent_id # trick ember
    end
  end
end
