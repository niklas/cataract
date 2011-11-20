module JqueryMobileHelper
  def for_header(&block)
    content_for :header, &block
  end
  def for_footer(&block)
    content_for :footer, &block
  end

  # addition options to those provided by apotomo's widget_div and rails' content_tag
  #   :role
  def mobile_tag(options = {}, &block)
    options.reverse_merge!('data-role' => options.delete(:role)) if options.has_key?(:role)
    options.reverse_merge!(:id => widget_id)
    tag_name = options.delete(:tag) || 'div'
    content_tag tag_name, options, &block
  end
end
