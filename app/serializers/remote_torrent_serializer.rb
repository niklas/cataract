class RemoteTorrentSerializer < BaseSerializer
  attributes :id,
             :title,
             :uri

  has_one :directory

  def id
    object.id
  end
end
