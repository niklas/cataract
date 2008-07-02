# Lcars
#
# Lcars.box "helm"
#
module Lcars
  module ClassMethods
    def box(name,opts={})
      LcarsBox.define_box name,opts
    end
  end
end
