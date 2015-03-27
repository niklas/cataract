class RemoteTorrentSerializer < BaseSerializer
  attributes :id, :title

  has_one :directory

  def id
    object.id
  end
end
