module Lcars
  class Box
    @@lcars_boxes = {}

    attr_reader :name
    attr_reader :opts

    def initialize(name, opts={})
      @name = name.to_sym
      @opts = opts
      raise "Invalid name for Lcars: #{name} (Blacklisted)" if InvalidLcarsNames.include?(name.to_s)
      raise "Invalid name for Lcars: #{name} (wrong format, must be proper DOM id)" unless name.to_s =~ /\A\w+\Z/
      @@lcars_boxes[name] = self
      build_methods
    end

    def install(dests)
      dests.each do |dest|
        dest.send! :include, @module
        dest.send! :include, RenderMethods
      end
    end

    [:title, :buttons, :content].each do |attrb|
      define_method attrb do
        opts[attrb]
      end
    end

    def build_methods
      @module ||= Module.new

      @module.module_eval <<-EOEVAL
        def update_#{name}(opts={})
          update_lcars_box(:#{name},opts)
        end
        def render_#{name}(opts={},&block)
          render_lcars_box(:#{name},opts,&block)
        end
        def reset_#{name}
          reset_lcars_box(:#{name})
        end
      EOEVAL
    end

    def list_of_lcars_boxes
      @@lcars_boxes.keys
    end
    
    def self.list_of_lcars_boxes
      @@lcars_boxes.keys
    end

    def self.by_name(name)
      all[name.to_sym]
    end

    def self.all
      @@lcars_boxes
    end

    module RenderMethods

      def update_lcars_box(name,opts={})
        replace_lcars_title   name, opts[:title]
        replace_lcars_buttons name, opts[:buttons]
        replace_lcars_content name, opts[:content]
        append_lcars_content  name, opts[:append_content]
        append_lcars_title    name, opts[:append_title]
        append_lcars_buttons  name, opts[:append_buttons]
        page[name].reset_behavior
      end

      def reset_lcars_box(name)
        box = Box.by_name(name)
        replace_lcars_title   name, box.title || ''
        replace_lcars_buttons name, box.buttons || []
        replace_lcars_content name, box.content || ''
        page[name].reset_behavior
      end


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
        return if buttons.nil?
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
        opts.reverse_merge! Lcars::Box::all[name].opts
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
        buttons = send!(buttons) if buttons.is_a? Symbol
        buttons = buttons.call if buttons.is_a? Proc
        return '' if buttons.blank?
        buttons.collect do |button|
          content_tag(:li,button)
        end.join(' ')
      end

      def lcars_title(title)
        title = send!(title) if title.is_a? Symbol
        title = title.call if title.is_a? Proc
        return '' if title.blank?
        content_tag(:span,h(title),{:class => 'title'})
      end

      def lcars_content_from_opts_or_block(opts = {},&block)
        returning '' do |content|
          c = opts[:content]
          c = c.call if c.is_a? Proc
          case c
          when Symbol
            content << send!(c)
          when Hash
            content << render(c) unless c.empty?
          when String
            content << c unless c.blank?
          end
          content << capture(&block) if block_given?
        end
      end
      def context
        page.instance_variable_get("@context").instance_variable_get("@template")
      end
    end
  end
end
