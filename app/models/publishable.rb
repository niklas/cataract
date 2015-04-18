module Publishable
  def publisher
    Cataract::Publisher
  end

  def publish(model=self, opts={})
    publisher.publish_record_update model, opts
  end

  def publish_resource(resource, opts={})
    publish(resource, opts)
  end

  def publish_destroy(model=self, opts={})
    publisher.publish_record_destroy model, opts
  end

  def publish_message(msg='something', opts={})
    publisher.publish 'message', opts.merge(text: msg)
  end
end
