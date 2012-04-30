FactoryGirl.define do
  factory :directory do
    sequence(:name) { |i| "Directory ##{i}" }
    sequence(:path) { |i| "directory_#{i}" }
    watched false

    disk

    factory :target # to move

    factory :existing_directory do
      auto_create true
    end

    after_build do |directory|
      if directory.path.relative? && defined?(FileSystem)
        directory.path = FileSystem.rootfs/directory.path
      end
    end
  end

  factory :move do
    torrent
    target
  end

  factory :disk do
    sequence(:name) { |i| "Disk ##{i}" }
    sequence(:path) { |i| "/tmp/disk#{i}" }

    after_build do |disk|
      if disk.path.relative? && defined?(FileSystem)
        disk.path = FileSystem.rootfs/disk.path
      end
    end
  end
end
