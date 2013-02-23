class DetectedDirectorySerializer < BaseSerializer
  attributes :name
  def attributes
    super.tap do |hash|
      hash['parent_id'] = object.parent.try(:id)
    end
  end
end
