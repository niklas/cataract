class TorrentSerializer < ActiveModel::Serializer
  attributes :id, :title, :info_hash, :status
end
