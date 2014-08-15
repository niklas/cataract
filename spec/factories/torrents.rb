FactoryGirl.define do
  chars = (0..9).to_a + ('A'..'F').to_a
  chars = chars + chars
  chars = chars + chars
  chars = chars + chars
  chars = chars + chars
  sequence :info_hash do |rnd|
    chars.sample(40, random: rnd).join
  end
  factory :remote_torrent, :class => 'Torrent' do
    status 'remote'
    sequence(:url) { |i| "http://cataract.local/#{i}.torrent" }
  end

  factory :torrent do
    info_hash
    sequence(:filename) { |i| "#{i}.torrent" }

    # this is just for migration
    factory :dirless_torrent do
      after :create do |torrent|
        Directory.delete_all id: torrent.directory_id
        Torrent.where(id: torrent.id).update_all( directory_id: nil)
      end
    end



    factory :running_torrent do
      status 'running'
    end
    factory :archived_torrent do
      status 'archived'
      factory :torrent_with_content
    end

    factory :torrent_with_file do
      info_hash nil
      status 'archived'
      after :build do |torrent|
        FileSystem.create_file torrent.path
      end
      # btmakemetafile tails.png http://127.0.0.1:6969/announce --target single.torrent
      factory :torrent_with_picture_of_tails do
        file { File.open FileSystem.file_factory_path/'single.torrent' }
      end

      # btmakemetafile content http://127.0.0.1:6969/announce --target multiple.torrent
      factory :torrent_with_picture_of_tails_and_a_poem do
        file { File.open FileSystem.file_factory_path/'multiple.torrent' }
      end
    end

  end

  factory :feed do
    sequence(:url) { |i| "http://cataract.local/#{i}.rss" }
  end
end
