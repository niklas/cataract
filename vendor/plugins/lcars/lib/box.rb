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
          page["#{name}"].reset_behavior
        end
        def reset_#{name}
          replace_lcars_title(:#{name},nil)
          replace_lcars_buttons(:#{name},nil)
          replace_lcars_content(:#{name},nil)
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
      return if content.nil?
      lcars_select(name,:content).each do |element|
        c = case content 
            when Hash
              context.render(content)
            when String
              content
            end
        element.update(c)
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
      opts.reverse_merge! @@options_for_lcars[name]
      kind = opts[:kind] || 'nws'
      theme = opts[:theme] || 'primary'
      rendered = 
        content_tag(
          :div,
            lcars_buttons_with_container(opts[:buttons]) +
            lcars_title(opts[:title]) +
            content_tag(
              :div,
              content_tag(
                :div,
                lcars_content_from_opts_or_block(opts,&block),
                {:class => 'content'}
              ),
              {:class => 'inner'}
            ),
          {:class => "lcars #{kind} #{theme}", :id => name.to_s}
        )
      concat(rendered,block.binding) if block_given?
      return rendered
    end

    def lcars_buttons_with_container(buttons)
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

    def lcars_content_from_opts_or_block(opts = {},&block)
      returning '' do |content|
        case opts[:content]
        when Hash
          content << render(opts[:content]) unless opts[:content].empty?
        when String
          content << opts[:content] unless opts[:content].blank?
        end
        content << capture(&block) if block_given?
      end
    end
    def context
      page.instance_variable_get("@context").instance_variable_get("@template")
    end
  end
end
