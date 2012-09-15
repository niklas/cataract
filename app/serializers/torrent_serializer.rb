class TorrentSerializer < BaseSerializer
  attributes :id, :title, :info_hash, :filename, :status

  has_one :payload

end
