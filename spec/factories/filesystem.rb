FactoryGirl.define do
  factory :directory do
    sequence(:name) { |i| "Directory ##{i}" }
    sequence(:path) { |i| "/tmp/directory_#{i}" }
    watched false

    factory :target # to move

    factory :existing_directory do
      auto_create true
    end

    after_create do |directory|
      directory.reload # force serialization
    end
  end

  factory :move do
    torrent
    target
  end
end
