module Maintenance
  class Base < ActiveRecord::Base
    set_table_name 'maintenances'
    include Queueable


    def work
      raise NotImplementedError, "implement #{self.class}#run"
    end
  end
end
