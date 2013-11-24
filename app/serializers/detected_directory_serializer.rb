class DetectedDirectorySerializer < BaseSerializer
  attributes :name
  def attributes
    super.tap do |hash|
      hash['id'] = object.name
      hash['parent_id'] = object.parent.try(:id)
      hash['disk_id'] = object.disk_id
      hash['relative_path'] = object.relative_path.to_s
    end
  end
end
