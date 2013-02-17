class DirectorySerializer < BaseSerializer
  embed :ids, include: false
  attributes :id, :name, :subscribed, :filter, :exists?, :show_sub_dirs?
  has_many :children, embed: :ids, key: 'children_ids'

  def attributes
    super.tap do |hash|
      hash['path'] = object.path.to_s
      hash['parent_id'] = object.parent.try(:id)
      hash['disk_id'] = object.disk_id
    end
  end
end
