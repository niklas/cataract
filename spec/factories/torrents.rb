FactoryGirl.define do
  factory :torrent do
    sequence(:title)    { |i| "Torrent ##{i}" }
    sequence(:filename) { |i| "#{i}.torrent" }
    sequence(:info_hash) { |i| "%0.40d" % i }
    directory

    factory :remote_torrent do
      status 'remote'
      sequence(:url) { |i| "http://cataract.local/#{i}.torrent" }
    end

    factory :running_torrent do
      status 'running'
    end
    factory :archived_torrent do
      status 'archived'
      factory :torrent_with_content
    end
  end
end
