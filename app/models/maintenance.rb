module Maintenance
  class Base < ActiveRecord::Base
    self.table_name = 'maintenances'
    include Queueable


    def work
      raise NotImplementedError, "implement #{self.class}#work"
    end

    def work!
      super
    end
  end
end
