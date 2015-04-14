require 'redis'
class Cataract::Publisher
  def self.publish(channel, message)
    channel = "message.#{channel}" unless channel.include?('.')
    redis.publish channel, message.to_json
  rescue Redis::CannotConnectError => e
    # Travis fails to start redis on 2015-04-05
    Rails.logger.warn { e.to_s }
  end

  def self.publish_record_update(record)
    serializer = record.active_model_serializer.new(record)
    publish 'update', serializer.to_json
  end

  def self.redis
    @redis ||= Redis.connect
  end
end
