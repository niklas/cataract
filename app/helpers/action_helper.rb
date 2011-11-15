module ActionHelper
  def translate_action(key,opts={})
    if key.present? && key.first == '.'
      t('helpers.actions' + key, opts)
    else
      key
    end
  end
  def link_to(text, *args, &block)
    super translate_action(text), *args, &block
  end
end
