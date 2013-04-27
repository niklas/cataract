class BaseSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper
  self.root = false # for emu
end

