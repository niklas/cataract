# helpers soon to be moved to jquery_mobile-rails

module MobileHelper
  def header(options={}, &block)
    mobile_tag options.reverse_merge(:role => 'header'), &block
  end

  def footer(options={}, &block)
    mobile_tag options.reverse_merge(:role =>  'footer'), &block
  end

  def content(options={}, &block)
    mobile_tag options.reverse_merge(:role =>  'content'), &block
  end
end
