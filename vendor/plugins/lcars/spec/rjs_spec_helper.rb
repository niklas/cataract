module RJSSpecHelper

  class HelperRJSPageProxy
    def initialize(context)
      @context = context
    end
  
    def method_missing(method, *arguments)
      block = Proc.new { |page|  @lines = []; page.send(method, *arguments) }
      @myresponse = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@context, &block).to_s
      @myresponse
    end
  end

  class SelectDomElement
    def initialize(select_string)
      @select_string = select_string
      mock_page
    end

    def matches?(target)
      @target = target
      @target == "foo"
    end

    def failure_message
      "manno, so siehts aus: #{@target}"
    end

    def mock_page
      @target.stub!(:page).and_return("amockpage")
    end
  end

  def rjs_for
    HelperRJSPageProxy.new(self)
  end
  def select_dom_element(expected)
    SelectDomElement.new(expected)
  end
end

