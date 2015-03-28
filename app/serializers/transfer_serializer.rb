class TransferSerializer < BaseSerializer
  embed :ids, include: true
  include TorrentsHelper
  attributes :torrent_id, :progress, :up_rate, :down_rate

  def attributes
    super.tap do |hash|
      unless object.arrived?
        hash['eta'] = time_left_in_words object.left_seconds
      else
        hash['eta'] = ' '
      end
      hash['id'] = object.torrent_id # trick ember
      hash[:active] = object.active? || false # FIXME rtorrent transfer/proxy redesign needed
    end
  end
end
