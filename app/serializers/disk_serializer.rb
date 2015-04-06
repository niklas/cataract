require_dependency 'base_serializer'
class DiskSerializer < BaseSerializer
  attributes :id,
             :name,
             :size,
             :free

  # TODO fetch only disks when polydisktree can act properly on PromisedArray
  # has_many   :directories

  def attributes
    super.tap do |a|
      a['is_mounted'] = object.mounted?
      a['path'] = object.path.to_s
    end
  end
end
