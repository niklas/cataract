class TorrentProgressSerializer < BaseSerializer
  include TorrentsHelper

  attributes :id, :status

  def attributes
    super.tap do |a|
      a['up_rate'] = human_bytes_rate object.up_rate
      a['down_rate'] = human_bytes_rate object.down_rate
    end
  end
end
