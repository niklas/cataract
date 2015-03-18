class DirectorySerializer < BaseSerializer
  attributes :id,
             :name,
             :subscribed,
             :exists?,
             :show_sub_dirs?
  has_one    :disk

  def attributes
    super.tap do |hash|
      hash['relative_path'] = object.relative_path.to_s
      hash['parent_id'] = object.parent.try(:id)
      hash['filter'] = object.filter
    end
  end
end
