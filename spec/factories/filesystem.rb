FactoryGirl.define do
  factory :directory do
    sequence(:name) { |i| "Directory ##{i}" }
    sequence(:relative_path) { |i| "directory_#{i}" }
    watched false

    disk

    factory :target # to move

    factory :existing_directory do
      auto_create true
    end
  end

  factory :move do
    torrent
    target
  end

  factory :disk do
    sequence(:name) { |i| "Disk ##{i}" }
    sequence(:path) { |i| "disk#{i}" }

    after_build do |disk|
      if disk.path? && disk.path.relative? && defined?(FileSystem)
        disk.path = FileSystem.rootfs/disk.path
      end
    end
  end
end
