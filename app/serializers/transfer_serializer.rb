class TransferSerializer < BaseSerializer
  embed :ids, include: true
  include TorrentsHelper
  attributes :torrent_id, :progress

  def attributes
    super.tap do |hash|
      hash['up_rate'] = human_bytes_rate object.up_rate
      hash['down_rate'] = human_bytes_rate object.down_rate
      unless object.arrived?
        hash['eta'] = time_left_in_words object.left_seconds
      end
      hash['id'] = object.torrent_id # trick ember
      hash[:active] = object.active?
    end
  end
end
