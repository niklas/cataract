require 'redis'
class Cataract::Publisher
  def self.publish(channel, message)
    redis.publish "message.#{channel}", message.to_json
  rescue Redis::CannotConnectError => e
    # Travis fails to start redis on 2015-04-05
    Rails.logger.warn { e.to_s }
  end

  def self.redis
    @redis ||= Redis.connect
  end
end
