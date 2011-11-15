module JqueryMobileHelper
  def for_header(&block)
    content_for :header, &block
  end
end
