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

  def button_to(text, *args, &block)
    super translate_action(text), *args, &block
  end

  def translate_icon(key, opts={})
    icon_tag(key, opts) + ' ' + translate_action(key, opts)
  end

  def icon_tag(key, opts={})
    content_tag(:i, '', class: "icon-#{Icons[key] || 'glass'} #{'icon-white' unless opts[:'non-white']}") + ' '
  end

  alias ti translate_icon

  alias i icon_tag

  Icons = {
    stop:  'stop',
    start: 'play',
    clear: 'trash',
    move:  'share',
    edit: 'pencil'
  }

  def link_to_icon icon_name, url, opts={}
    opts[:class] = "#{opts[:class]} #{icon_name}"
    unless opts.delete(:link_only)
      opts[:class] += " btn btn-mini"
    end
    link_to ti(icon_name, opts.delete(:icon) || {}), url, opts
  end

  def boolean_tag(record, predicate)
    val = record.send(predicate)
    content_tag :span, I18n.t(val.to_s, scope: 'helpers.boolean'), class: "#{val}"
  end
end
