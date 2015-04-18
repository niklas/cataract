module Publishable
  def publish(model=self)
    Cataract::Publisher.publish_record_update model
  end

  def publish_destroy(model=self)
    Cataract::Publisher.publish_record_destroy model
  end
end
