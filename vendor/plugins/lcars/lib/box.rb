module LcarsBox
  module InstanceMethods
    @@list_of_lcars_boxes = []
    @@options_for_lcars = {}
    def define_box(name, opts = {})
      @@list_of_lcars_boxes << name

      kind = extract_lcars_kind_from_opts(opts)

      eval <<-EOMETH
        def update_#{name}(opts = {}, &block)
          "foo"
        end
        def render_#{name}(opts = {}, &block)
          concat content_tag(
            :div,
              lcars_buttons(opts[:buttons]) +
              lcars_title(opts[:title]) +
              lcars_content_from_block(&block),
            {:class => 'lcars #{kind}'}
          ), block.binding
        end
      EOMETH
    end
    def list_of_lcars_boxes
      @@list_of_lcars_boxes
    end
    def extract_lcars_kind_from_opts(opts = {})
      opts.delete(:kind) || 'nes'
    end

    def lcars_buttons(buttons)
      return '' if buttons.blank?
      content_tag(
        :ul,
        buttons.collect do |button|
          content_tag(:li,button)
        end.join(' '),
        {:class => 'buttons'}
      )
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
  end
end
