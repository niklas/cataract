require 'redis'
class Cataract::Publisher
  def self.publish(channel, message)
    channel = "message.#{channel}" unless channel.include?('.')
    content = message.to_json
    Rails.logger.debug { "Publish #{channel} #{content}" }
    redis.publish channel, content
  rescue Redis::CannotConnectError => e
    # Travis fails to start redis on 2015-04-05
    Rails.logger.warn { e.to_s }
  end

  def self.publish_record_update(record)
    return unless record.persisted?
    serializer = record.active_model_serializer.new(record)
    publish record.class.model_name.element, serializer
  end

  def self.redis
    @redis ||= Redis.connect
  end
end
