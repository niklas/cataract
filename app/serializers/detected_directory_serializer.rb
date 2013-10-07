class DetectedDirectorySerializer < BaseSerializer
  attributes :name
  def attributes
    super.tap do |hash|
      hash['id'] = object.name
      hash['parent_id'] = object.parent.try(:id)
      hash['disk_id'] = object.disk_id
    end
  end
end
