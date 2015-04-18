require 'redis'
class Cataract::Publisher
  class CannotPublish < StandardError
    def message
      "cannot publish: #{super}"
    end
  end
  class HasNoId < CannotPublish
    def message
      "#{super}: has no id"
    end
  end

  def self.publish(channel, message, opts={})
    channel = "message.#{channel}" unless channel.include?('.')
    content = message.merge('_meta' => opts).to_json
    Rails.logger.debug { "Publish #{channel} #{content}" }
    redis.publish channel, content
  rescue Redis::CannotConnectError => e
    # Travis fails to start redis on 2015-04-05
    Rails.logger.warn { e.to_s }
  rescue HasNoId => e
    Rails.logger.warn { e.message }
  end

  def self.publish_record_update(record, opts={})
    serializer = ensure_record_has_id!(record)
    publish record.class.model_name.element, serializer.as_json, opts
  end

  def self.publish_record_destroy(record, opts={})
    serializer = ensure_record_has_id!(record)
    id = serializer.attributes[:id]
    publish 'delete_' + record.class.model_name.element, {id: id}, opts
  end

  def self.ensure_record_has_id!(record)
    serializer = record.active_model_serializer.new(record)
    id = serializer.attributes[:id]
    raise HasNoId unless id # ember-data needs an id

    serializer
  end

  def self.redis
    @redis ||= Redis.connect
  end
end
