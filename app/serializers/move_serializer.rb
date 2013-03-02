class MoveSerializer < BaseSerializer
  attributes :id, :torrent_id, :target_directory_id, :target_disk_id, :title
end
