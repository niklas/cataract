class DiskSerializer < BaseSerializer
  attributes :id, :name

  def attributes
    super.tap do |a|
      a['is_mounted'] = object.mounted?
    end
  end
end
