class Maintenance::CachePayloadExists < Maintenance::Base
  def work
    Torrent.transaction do
      Torrent.find_in_batches batch_size: 333 do |batch|
        batch.each do |torrent|
          begin
            really = torrent.payload.exists?
            cached = torrent.payload_exists?

            if really != cached
              torrent.payload_exists = really
              logger.info { "Torrent #{torrent.id} really #{really ? 'has' : 'has no'} payload" }
              torrent.save!
            end
          rescue StandardError => e
            logger.warn { "Could not check Torrent #{torrent.id}'s content: #{e}" }
          end
        end
      end
    end
  end
end
