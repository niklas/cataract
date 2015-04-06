class DirectorySerializer < BaseSerializer
  attributes :id,
             :name,
             :subscribed,
             :exists?,
             :show_sub_dirs?
  # we usually load all directories + disk on startup, so we can assume certain # things:
  has_one    :disk,             include: false # it includes us already

  def attributes
    super.tap do |hash|
      hash['relative_path'] = object.relative_path.to_s
      hash['filter'] = object.filter
      hash['parent_directory_id'] = object.parent_id
    end
  end

  def parent_directory
    object.parent
  end
end
