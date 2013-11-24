class DiskSerializer < BaseSerializer
  attributes :id, :name, :directory_ids

  def attributes
    super.tap do |a|
      a['is_mounted'] = object.mounted?
      a['path'] = object.path.to_s
    end
  end
end
