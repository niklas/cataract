class TorrentProgressSerializer < BaseSerializer
  include TorrentsHelper

  attributes :id, :status, :progress
  root 'torrent'

  def attributes
    super.tap do |a|
      a['up_rate'] = human_bytes_rate object.up_rate
      a['down_rate'] = human_bytes_rate object.down_rate
      a['eta'] = time_left_in_words object.left_seconds
    end
  end
end
