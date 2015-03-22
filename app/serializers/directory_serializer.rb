class DirectorySerializer < BaseSerializer
  attributes :id,
             :name,
             :subscribed,
             :exists?,
             :show_sub_dirs?
  has_one    :disk
  has_one    :parent_directory

  def attributes
    super.tap do |hash|
      hash['relative_path'] = object.relative_path.to_s
      hash['filter'] = object.filter
    end
  end

  def parent_directory
    object.parent
  end
end
