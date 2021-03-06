FactoryGirl.define do
  factory :directory do
    sequence(:name) { |i| "Directory ##{i}" }
    sequence(:relative_path) { |i| "directory_#{i}" }
    watched false
    virtual true

    disk

    factory :target_directory # to move
    factory :incoming_directory do
      sequence(:name) { |i| "Incoming ##{i}" }
      sequence(:relative_path) { |i| "incoming_#{i}" }
    end

    factory :existing_directory do
      virtual false
    end
  end

  factory :blank_directory, class: 'Directory' do
    virtual true
  end

  factory :move do
    torrent
    target_directory
  end

  factory :disk do
    sequence(:name) { |i| "Disk ##{i}" }
    sequence(:path) { |i| "disk#{i}" }

    after :build do |disk|
      if disk.path? && disk.path.relative? && defined?(FileSystem)
        disk.path = FileSystem.rootfs/disk.path
      end
    end
  end
end
