class Maintenance::CachePayloadExists < Maintenance::Base
  def work
    Torrent.transaction do
      Torrent.find_in_batches batch_size: 333 do |batch|
        batch.each do |torrent|
          really = torrent.payload.exists?
          cached = torrent.payload_exists?

          if really != cached
            torrent.payload_exists = really
            torrent.save!
          end
        end
      end
    end
  end
end
