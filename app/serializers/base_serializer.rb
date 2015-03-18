class BaseSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper
  embed :ids, include: true
end

