module ModalDecoratorHelper

  # wraps the given block in modal divs. Must give at least :body
  def modal(options = {})
    body    = options.delete(:body) || raise(ArgumentError, 'no :body given for modal')
    header  = options.delete(:header)
    classes = options.delete(:class)
    content_body = h.content_tag :div, body, class: 'modal-body'
    if header
      content = h.content_tag(:div, header, class: 'modal-header')
      content += content_body
    else
      content = content_body
    end
    h.content_tag :div, content, options.merge(class: "modal container-fluid hide fade in #{classes}")
  end

  # removes all modal boxes first, appends a new one to the body and opens it
  def append_modal(options = {})
    select(:modal).remove()
    page.select('body').append(modal(options))
    select(:modal).modal('show')
  end

  def append_to_modal(html)
    select(:modal).append html
  end

  def selector_for(name, *more)
    case name
    when :modal
      '.modal'
    else
      super
    end
  end

  def hide_modal(*a)
    if a.empty?
      page.select('.modal')
    else
      select(*a)
    end.modal('hide')
  end

  alias close_modal hide_modal

end
