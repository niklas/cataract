module Publishable
  def publisher
    Cataract::Publisher
  end

  def publish(model=self, opts={})
    publisher.publish_record_update model, opts
  end

  alias_method :publish_resource, :publish

  def publish_destroy(model=self, opts={})
    publisher.publish_record_destroy model, opts
  end

  def publish_message(msg='something', opts={})
    publisher.publish 'message', opts.merge(text: msg)
  end
end
