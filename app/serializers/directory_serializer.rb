class DirectorySerializer < BaseSerializer
  attributes :id, :name

  def attributes
    super.tap do |hash|
      hash['path'] = object.path.to_s
    end
  end
end
