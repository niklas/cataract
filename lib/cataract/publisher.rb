require 'redis'
class Cataract::Publisher
  def self.publish(channel, message)
    redis.publish "message.#{channel}", message.to_json
  end

  def self.redis
    @redis ||= Redis.connect
  end
end
