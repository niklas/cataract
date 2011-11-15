module JqueryMobileHelper
  def for_header(&block)
    content_for :header, &block
  end
  def for_footer(&block)
    content_for :footer, &block
  end
end
