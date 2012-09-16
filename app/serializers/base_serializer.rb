class BaseSerializer < ActiveModel::Serializer
  embed :ids, include: true
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper
end

