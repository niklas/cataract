class Maintenance < ActiveRecord::Base
  self.abstract_class = true

  include Queueable

  def run
    raise NotImplemented, "implement #{self.class}#run"
  end
end
