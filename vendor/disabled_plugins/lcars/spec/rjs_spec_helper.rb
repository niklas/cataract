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
    end

    def matches?(generated_rjs)
      @generated_rjs = generated_rjs
      @unescaped_rjs = unescape_rjs(@generated_rjs)
      if @replace_string
        @unescaped_rjs =~ select_and_replace_re(@select_string,@replace_string)
      elsif @append_string
        @unescaped_rjs =~ select_and_append_re(@select_string,@append_string)
      else
        @unescaped_rjs =~ select_and_replace_re(@select_string)
      end
    end

    def select_and_replace_re(sel,repl=nil)
      s = Regexp.escape(sel)
      r = repl.blank? ? '.*?' : Regexp.escape(repl)
      %r~\$\$\("#{s}"\).each\(function\(value,\s?index\)\s?\{\s*value.update\("#{r}"\);\s*\}\);~sm
    end

    def select_and_append_re(sel,append)
      s = Regexp.escape(sel)
      a = Regexp.escape(append)
      %r~\$\$\("#{s}"\).each\(function\(value,\s?index\)\s?\{\s*value.insert\("#{a}"\);\s*\}\);~sm
    end

    def failure_message
      "did not select '#{@select_string}'" + 
      (@replace_string.blank? ? '' : " and replaced it with '#{@replace_string}'") +
      " got rjs: \n  ===\n#{@unescaped_rjs}\n  ===\n"
    end

    def negative_failure_message
      "did select '#{@select_string}'" + 
      (@replace_string.blank? ? '' : " and replaced it with '#{@replace_string}'") +
      " got rjs: \n  ===\n#{@unescaped_rjs}\n  ===\n"
    end

    def and_replace_with(replace_string)
      @replace_string = replace_string
      self
    end

    def and_append(append_string)
      @append_string = append_string
      self
    end

    def mock_page
      @target.stub!(:page).and_return("amockpage")
    end

    # Unescapes a RJS string.
    def unescape_rjs(rjs_string)
      # RJS encodes double quotes and line breaks.
      rjs_string.gsub('\"', '"').
      gsub(/\\\//, '/').
      gsub('\n', "\n").
      gsub('\076', '>').
      gsub('\074', '<').
      # RJS encodes non-ascii characters.
      gsub(/\\u([0-9a-zA-Z]{4})/) {|u| [$1.hex].pack('U*')}
    end
  end

  def rjs_for
    HelperRJSPageProxy.new(self)
  end
  def select_dom_element(expected)
    SelectDomElement.new(expected)
  end
end

