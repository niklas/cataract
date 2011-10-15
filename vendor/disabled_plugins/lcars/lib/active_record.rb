module Lcars
  module ActiveRecord
    def self.included(base)
      #base.extend(ClassMethods)
      base.class_eval { include InstanceMethods  }
    end

    module InstanceMethods
      def class_name
        self.class.to_s
      end

      def table_name
        self.class.table_name
      end
    end
  end
end
