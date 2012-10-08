class DirectorySerializer < BaseSerializer
  embed :ids, include: false
  attributes :id, :name
  has_many :children, embed: :ids

  def attributes
    super.tap do |hash|
      hash['path'] = object.path.to_s
      hash['is_existing'] = object.exist?
      hash['parent_id'] = object.parent.try(:id)
      hash['disk_id'] = object.disk_id
      hash['show_sub_dirs'] = object.show_sub_dirs?
    end
  end
end
