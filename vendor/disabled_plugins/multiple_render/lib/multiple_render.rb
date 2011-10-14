module MultipleRender
  module ActionController
    module SingletonMethods
      def self.included(receiver)
        receiver.class_eval do
          helper MultipleRender::ActionController::HelperMethods
          include MultipleRender::ActionController::InstanceMethods
          extend MultipleRender::ActionController::ClassMethods
        end
      end
    end

    module HelperMethods
      # Modified Version of update_page which renders the blocks
      # given by +update_page+ and +after_update_page+
      def update_page(&block)
        gen = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@template, &block)
        @blocks_to_render.each do |blk|
          blk.call gen
        end if @blocks_to_render
        logger.debug("update_page from #{@controller} with #{@controller.after_update_page_hooks}")
        @controller.after_update_page_hooks.each do |meth|
          @controller.send meth, gen
        end
        gen.to_s
      end
    end

    module InstanceMethods
      # call in your action (multiple times)
      # render_update do |page|
      #   page.update 'foo', 'barz'
      # end
      def render_update &blk
        @blocks_to_render ||= []
        @blocks_to_render << blk
      end

      def after_update_page_hooks
        self.class.renderer_chain
      end
    end

    module ClassMethods
      # names of methods to call with +page+ after all other blocks aere executed
      def after_update_page(meth)
        renderer_chain << meth
        ActiveRecord::Base::logger.debug "#{self} registered aup: #{meth}, now have #{renderer_chain.inspect}"
      end

      def renderer_chain
        if chain = read_inheritable_attribute('renderer_chain')
          return chain
        else
          write_inheritable_attribute('renderer_chain', Set.new)
          return renderer_chain
        end
      end
    end
  end
end

