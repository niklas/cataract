module JqueryMobileHelper
  Roles = %w(
    page
    header
    content
    footer
  )

  Roles.each do |role|
    module_eval <<-EODEF, __FILE__, __LINE__
      def #{role}(opts = {}, &block)
        content_tag :div, jquery_mobile_options(opts, :role => '#{role}'), &block
      end
    EODEF
  end

  def jquery_mobile_options(opts, more={})
    opts.merge(more) do |o|
      if role = o.delete(:role)
        o['data-role'] = role
      end
    end
  end
end
