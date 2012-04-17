module ActionHelper
  def translate_action(key,opts={})
    if key.is_a?(Symbol)
      t("helpers.actions.#{key}", opts)
    elsif key.present? && key.first == '.'
      t("helpers.actions#{key}", opts)
    else
      key
    end
  end
  alias ta translate_action

  def link_to(text, *args, &block)
    super translate_action(text), *args, &block
  end

  def translate_icon(key, opts={})
    icon_tag(key) + ' ' + translate_action(key, opts)
  end

  def icon_tag(key)
    content_tag(:i, '', class: "icon-#{Icons[key] || 'glass'} icon-white")
  end

  alias ti translate_icon

  alias i icon_tag

  Icons = {
    stop:  'stop',
    start: 'play',
    clear: 'trash',
    move:  'share'
  }

  def link_to_icon icon_name, url, opts={}
    opts = opts.merge(remote: true)
    opts[:class] = "#{opts[:class]} #{icon_name} btn btn-mini"
    link_to i(icon_name), url, opts
  end
end
