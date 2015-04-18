require_dependency 'base_serializer'
class DiskSerializer < BaseSerializer
  attributes :id,
             :name,
             :size,
             :free,
             :is_mounted,
             :path

  # TODO fetch only disks when polydisktree can act properly on PromisedArray
  # has_many   :directories

  def is_mounted
    object.mounted?
  end

  def path
    object.path.to_s
  end
end
