class DirectorySerializer < BaseSerializer
  attributes :id, :name

  def attributes
    super.tap do |hash|
      hash['path'] = object.path.to_s
      hash['is_existing'] = object.exist?
      hash['parent_id'] = object.parent.try(:id)
      hash['disk_id'] = object.disk_id
    end
  end
end
