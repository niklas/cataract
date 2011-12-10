FactoryGirl.define do
  factory :directory do
    sequence(:name) { |i| "Directory ##{i}" }
    sequence(:path) { |i| "/tmp/directory_#{i}" }
    watched false

    factory :target # to move

    factory :existing_directory do
      after_create do |d|
        FileUtils.mkdir_p d.path
      end
    end
  end

  factory :move do
    torrent
    target
  end
end
