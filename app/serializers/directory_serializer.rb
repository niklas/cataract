class DirectorySerializer < BaseSerializer
  attributes :id,
             :name,
             :subscribed,
             :exists?,
             :relative_path,
             :parent_directory_id,
             :show_sub_dirs?
  # we usually load all directories + disk on startup, so we can assume certain # things:
  has_one    :disk

  def attributes
    super.tap do |hash|
      # collides with AMS internals
      hash[:filter] = object.filter
    end
  end

  def parent_directory_id
    object.parent_id
  end

  def relative_path
    object.relative_path.to_s
  end
end
