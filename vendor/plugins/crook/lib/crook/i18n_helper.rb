module Crook::I18nHelper
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

  def localized_locales
    I18n.available_locales.map do |locale|
      I18n.with_locale locale do
        [locale, t('_name')]
      end
    end
  end
  def localized_locales
    I18n.available_locales.map do |locale|
      I18n.with_locale locale do
        [locale, t('_name')]
      end
    end
  end
end
