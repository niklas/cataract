FactoryGirl.define do
  factory :remote_torrent, :class => Torrent do
    status 'remote'
    sequence(:url) { |i| "http://cataract.local/#{i}.torrent" }
  end

  factory :torrent do
    sequence(:info_hash) { |i| "%0.40d" % i }
    sequence(:filename) { |i| "#{i}.torrent" }

    directory

    # this is just for migration
    factory :dirless_torrent do
      after_create do |torrent|
        Directory.delete_all id: torrent.directory_id
        Torrent.update_all({ directory_id: nil}, { id: torrent.id })
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
      filename 'please-use-a-sub-factory.torrent'
      status 'archived'
      after_build do |torrent|
        FileSystem.create_file torrent.path
      end
      # btmakemetafile tails.png http://127.0.0.1:6969/announce --target single.torrent
      factory :torrent_with_picture_of_tails do
        filename 'single.torrent'
      end

      # btmakemetafile content http://127.0.0.1:6969/announce --target multiple.torrent
      factory :torrent_with_picture_of_tails_and_a_poem do
        filename 'multiple.torrent'
      end
    end

    after_build do |torrent|
      unless torrent.content_path.blank?
        path = Pathname.new(torrent.content_path)
        if path.relative?
          torrent.content_path = (FileSystem.rootfs/path).to_s
        end
      end
    end

  end
end
