module JqueryMobileHelper
  def for_header(options={}, &block)
    @header_options = options
    content_for :header, &block
  end
  def for_footer(options={}, &block)
    @footer_options = options
    content_for :footer, &block
  end

  attr_reader :header_options
  attr_reader :content_options
  attr_reader :footer_options

  # addition options to those provided by apotomo's widget_div and rails' content_tag
  #   :role
  def mobile_tag(options = {}, &block)
    options.reverse_merge!('data-role' => options.delete(:role)) if options.has_key?(:role)
    options.reverse_merge!(:id => widget_id) if respond_to?(:widget_id)
    options.reverse_merge!('data-position' => 'fixed') if options.delete(:fixed)
    options.reverse_merge!('data-theme' => options.delete(:theme)) if options.has_key?(:theme)
    tag_name = options.delete(:tag) || 'div'
    content_tag tag_name, options, &block
  end

# TODO put into own helper or even gem ('congenial')
  def add_class_to_html_options(opts, cls)
    if opts.has_key?(:class)
      if opts[:class] !~ /\b#{cls}\b/
        opts[:class] = %Q~#{opts[:class]} #{cls}~
      end
    else
      opts[:class] = cls
    end
  end
end
