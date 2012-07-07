module BootstrapHelper
  # for dropdowns
  def caret_tag(opts={})
    content_tag(:b,'',class: 'caret')
  end
end
