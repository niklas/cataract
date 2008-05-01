module LcarsBox
  module InstanceMethods
    @@list_of_lcars_boxes = []
    @@options_for_lcars = {}
    InvalidLcarsNames = %w(page update)
    def define_box(name, opts = {})
      raise "Invalid name for Lcars: #{name} (Blacklisted)" if InvalidLcarsNames.include?(name.to_s)
      raise "Invalid name for Lcars: #{name} (wrong format, must be proper DOM id)" unless name.to_s =~ /\A\w+\Z/

      @@list_of_lcars_boxes << name
      @@options_for_lcars[name] = opts

      eval <<-EOMETH
        def update_#{name}(opts = {})
          replace_lcars_title(:#{name},opts[:title])
          replace_lcars_buttons(:#{name},opts[:buttons])
          replace_lcars_content(:#{name},opts[:content])
          append_lcars_content(:#{name},opts[:append_content])
          append_lcars_title(:#{name},opts[:append_title])
          append_lcars_buttons(:#{name},opts[:append_buttons])
        end
        def render_#{name}(opts = {}, &block)
          render_lcars_box(:#{name}, opts, &block)
        end
      EOMETH
    end
    def list_of_lcars_boxes
      @@list_of_lcars_boxes
    end

    # Selectors
    def lcars_select(name,element)
      selector = "div.lcars##{name} > " +
                 case element
                 when :title
                   '.title'
                 when :content
                   'div.inner > div.content'
                 when :buttons
                   '.buttons'
                 else
                   raise "Illegal element for Lcars: #{element}"
                 end
      page.select(selector)
    end

    # Replace Elements
    def replace_lcars_title(name,title=nil)
      return unless title
      lcars_select(name,:title).each do |element|
        element.update(title)
      end
    end

    def replace_lcars_buttons(name,buttons=nil)
      return if buttons.blank?
      lcars_select(name,:buttons).each do |element|
        element.update(context.lcars_buttons(buttons))
      end
    end

    def replace_lcars_content(name,content=nil)
      return if content.blank?
      lcars_select(name,:content).each do |element|
        element.update(content)
      end
    end

    # Append Elements
    def append_lcars_content(name,content=nil)
      return if content.blank?
      lcars_select(name,:content).each do |element|
        element.insert content
      end
    end

    def append_lcars_buttons(name,buttons=nil)
      return if buttons.blank?
      lcars_select(name,:buttons).each do |element|
        element.insert(context.lcars_buttons(buttons))
      end
    end

    def append_lcars_title(name,title=nil)
      return if title.blank?
      lcars_select(name,:title).each do |element|
        element.insert title
      end
    end

    # Rendering
    def render_lcars_box(name, opts={}, &block)
      opts.merge! @@options_for_lcars[name]
      kind = opts[:kind]
      concat content_tag(
        :div,
          lcars_buttons_with_container(opts[:buttons]) +
          lcars_title(opts[:title]) +
          lcars_content_from_block(&block),
        {:class => "lcars #{kind}", :id => name.to_s}
      ), block.binding
    end

    def lcars_buttons_with_container(buttons)
      return '' if buttons.blank?
      content_tag(
        :ul,
        lcars_buttons(buttons),
        {:class => 'buttons'}
      )
    end
    def lcars_buttons(buttons)
      return '' if buttons.blank?
      buttons.collect do |button|
        content_tag(:li,button)
      end.join(' ')
    end

    def lcars_title(title)
      return '' if title.blank?
      content_tag(:span,h(title),{:class => 'title'})
    end

    def lcars_content_from_block(&block)
      content_tag(
        :div,
        content_tag(
          :div,
          capture(&block),
          {:class => 'content'}
        ),
        {:class => 'inner'}
      )
    end
    def context
      page.instance_variable_get("@context").instance_variable_get("@template")
    end
  end
end
