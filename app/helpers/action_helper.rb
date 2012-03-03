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
    content_tag(:i, '', class: "icon-#{Icons[key] || 'glass'} icon-white") + ' ' + translate_action(key, opts)
  end

  alias ti translate_icon

  Icons = {
    stop:  'stop',
    start: 'play',
    move:  'share'
  }
end
