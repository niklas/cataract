module Maintenance
  class Base < ActiveRecord::Base
    self.table_name = 'maintenances'
    include Queueable


    def work
      raise NotImplementedError, "implement #{self.class}#work"
    end

    def work!
      super
      if self.class.used_xbmc?
        xbmc.flush
      end
    end

    private
    def xbmc
      self.class.xbmc
    end

    def self.xbmc
      @xbmc ||= ActiveSupport::BufferedLogger.new Rails.root/'log'/"xbmc_updates.#{Rails.env}.log"
    end

    def self.used_xbmc?
      @xbmc
    end
  end
end
