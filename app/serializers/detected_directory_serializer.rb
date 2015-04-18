class DetectedDirectorySerializer < BaseSerializer
  attributes :name,
             :id,
             :disk_id,
             :relative_path
  has_one    :parent_directory, embed: :ids, include: false

  def parent_directory
    object.parent
  end

  def id
    object.name
  end

  def disk_id
    object.disk_id
  end

  def relative_path
    object.relative_path.to_s
  end
end
