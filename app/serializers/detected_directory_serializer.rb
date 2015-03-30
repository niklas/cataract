class DetectedDirectorySerializer < BaseSerializer
  attributes :name
  has_one    :parent_directory, embed: :ids, include: false
  def attributes
    super.tap do |hash|
      hash['id'] = object.name
      hash['disk_id'] = object.disk_id
      hash['relative_path'] = object.relative_path.to_s
    end
  end

  def parent_directory
    object.parent
  end
end
