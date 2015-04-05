class RemoteTorrentSerializer < BaseSerializer
  attributes :id,
             :title,
             :size,
             :uri

  has_one :directory

  def id
    object.id
  end
end
