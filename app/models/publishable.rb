module Publishable
  def publish(model=self)
    Cataract::Publisher.publish_record_update model
  end
end
