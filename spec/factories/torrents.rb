FactoryGirl.define do
  factory :torrent do
    sequence(:title)    { |i| "Torrent ##{i}" }
    sequence(:info_hash) { |i| "%0.40d" % i }
    sequence(:filename) { |i| "#{i}.torrent" }
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

    factory :torrent_with_file do
      # btmakemetafile tails.png http://127.0.0.1:6969/announce --target single.torrent
      factory :torrent_with_picture_of_tails do
        filename 'single.torrent'
      end

      # btmakemetafile content http://127.0.0.1:6969/announce --target multiple.torrent
      factory :torrent_with_picture_of_tails_and_a_poem do
        filename 'multiple.torrent'
      end
    end
  end
end
