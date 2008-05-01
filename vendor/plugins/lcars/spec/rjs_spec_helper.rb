module RJSSpecHelper
  class HelperRJSPageProxy
    def initialize(context)
      @context = context
    end
  
    def method_missing(method, *arguments)
      block = Proc.new { |page|  @lines = []; page.send(method, *arguments) }
      @context.response.body = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@context, &block).to_s
      @context.response
    end
  end

  def rjs_for
    HelperRJSPageProxy.new(self)
  end
end

