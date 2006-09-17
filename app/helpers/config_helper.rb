module ConfigHelper
  def in_place_settings_text_field(name,help=nil)
    content_tag('b', name) + ':&nbsp;' +
    content_tag('span', Settings[name], :id => name, :class => 'editfield') +
    (help ? content_tag('div', help, {:class => 'help'}) : '') +
    in_place_editor(name,
      :url => { :action => 'save_setting', :var => name },
      :rows => 1, :cols => 42,
      :submit_on_blur => true)
  end
end
