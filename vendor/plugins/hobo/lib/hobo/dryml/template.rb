require 'rexml/document'

module Hobo::Dryml

  class Template

    DRYML_NAME = "[a-zA-Z_][a-zA-Z0-9_]*"
    DRYML_NAME_RX = /^#{DRYML_NAME}$/
    
    CODE_ATTRIBUTE_CHAR = "&"
    
    SPECIAL_ATTRIBUTES = %w(param merge merge_params merge_attrs 
                            for_type 
                            if unless repeat 
                            part part_locals
                            restore)

    @build_cache = {}
    
    class << self
      attr_reader :build_cache

      def clear_build_cache
        @build_cache.clear()
      end
    end

    def initialize(src, environment, template_path)
      @src = src

      @environment = environment # a class or a module

      @template_path = template_path.sub(/^#{Regexp.escape(RAILS_ROOT)}/, "")

      @builder = Template.build_cache[@template_path] || DRYMLBuilder.new(@template_path)
      @builder.set_environment(environment)

      @last_element = nil
    end

    attr_reader :tags, :template_path
    
    def compile(local_names=[], auto_taglibs=[])
      now = Time.now

      unless @template_path.ends_with?(EMPTY_PAGE)
        filename = RAILS_ROOT + (@template_path.starts_with?("/") ? @template_path : "/" + @template_path)
        mtime = File.stat(filename).mtime rescue nil
      end
        
      if mtime.nil? || !@builder.ready?(mtime)
        @builder.clear_instructions
        parsed = true
        # parse the DRYML file creating a list of build instructions
        if is_taglib?
          process_src
        else
          create_render_page_method
        end

        # store build instructions in the cache
        Template.build_cache[@template_path] = @builder
      end

      # compile the build instructions
      @builder.build(local_names, auto_taglibs)

      from_cache = (parsed ? '' : ' (from cache)')
      logger.info("  DRYML: Compiled#{from_cache} #{template_path} in %.2fs" % (Time.now - now))
    end
      

    def create_render_page_method
      erb_src = process_src
      @builder.add_build_instruction(:render_page, :src => erb_src, :line_num => 1)
    end

    
    def is_taglib?
      @environment.class == Module
    end

    
    def process_src
      # Replace <%...%> scriptlets with xml-safe references into a hash of scriptlets
      @scriptlets = {}
      src = @src.gsub(/<%(.*?)%>/m) do
        _, scriptlet = *Regexp.last_match
        id = @scriptlets.size + 1
        @scriptlets[id] = scriptlet
        newlines = "\n" * scriptlet.count("\n")
        "[![HOBO-ERB#{id}#{newlines}]!]"
      end

      @xmlsrc = "<dryml_page>" + src + "</dryml_page>"
      begin
        @doc = REXML::Document.new(RexSource.new(@xmlsrc), :dryml_mode => true)
      rescue REXML::ParseException => e
        raise DrymlSyntaxError, "File: #{@template_path}\n#{e}"
      end
      @doc.default_attribute_value = "&true"
      
      restore_erb_scriptlets(children_to_erb(@doc.root))
    end


    def restore_erb_scriptlets(src)
      src.gsub(/\[!\[HOBO-ERB(\d+)\s*\]!\]/m) {|s| "<%#{@scriptlets[$1.to_i]}%>" }
    end

    
    def children_to_erb(nodes)
      nodes.map{|x| node_to_erb(x)}.join
    end
 

    def node_to_erb(node)
      case node

      # v important this comes before REXML::Text, as REXML::CData < REXML::Text
      when REXML::CData
        REXML::CData::START + node.to_s + REXML::CData::STOP
        
      when REXML::Comment
        REXML::Comment::START + node.to_s + REXML::Comment::STOP

      when REXML::Text
        node.to_s

      when REXML::Element
        element_to_erb(node)
      end
    end


    def element_to_erb(el)
      dryml_exception("parameter tags (<#{el.name}>) are no more, wake up and smell the coffee", el) if
        el.name.starts_with?(":")

      @last_element = el
      case el.dryml_name

      when "include"
        include_element(el)
        # return nothing - the include has no presence in the erb source
        tag_newlines(el)
        
      when "set_theme"
        require_attribute(el, "name", /^#{DRYML_NAME}$/)
        @builder.add_build_instruction(:set_theme, :name => el.attributes['name'])

        # return nothing - set_theme has no presence in the erb source
        tag_newlines(el)

      when "def"
        def_element(el)
        
      when "tagbody"
        tagbody_element(el)
        
      when "set"
        set_element(el)
        
      when "set_scoped"
        set_scoped_element(el)
        
      when "default_tagbody"
        default_tagbody_element(el)
        
      else
        if el.dryml_name.not_in?(Hobo.static_tags) || el.attributes['param'] || el.attributes['restore']
          if el.dryml_name =~ /^[A-Z]/
            template_call(el)
          else
            tag_call(el)
          end
        else
          static_element_to_erb(el)
        end
      end
    end


    def include_element(el)
      require_toplevel(el)
      require_attribute(el, "as", /^#{DRYML_NAME}$/, true)
      if el.attributes["src"]
        @builder.add_build_instruction(:include, 
                                       :name => el.attributes["src"], 
                                       :as => el.attributes["as"])
      elsif el.attributes["module"]
        @builder.add_build_instruction(:module, 
                                       :name => el.attributes["module"], 
                                       :as => el.attributes["as"])
      end
    end
    

    def import_module(mod, as=nil)
      @builder.import_module(mod, as)
    end


    def set_element(el)
      assigns = el.attributes.map do |name, value|
        dryml_exception(el, "invalid name in set") unless name =~ /^#{DRYML_NAME}(\.#{DRYML_NAME})*$/
        "#{name} = #{attribute_to_ruby(value)}; "
      end.join
      code = apply_control_attributes("begin; #{assigns}; end", el)
      "<% #{assigns}#{tag_newlines(el)} %>"
    end
    
    
    def set_scoped_element(el)
      assigns = el.attributes.map do |name, value|
        dryml_exception(el, "invalid name in set_scoped") unless name =~ DRYML_NAME_RX
        "scope[:#{name}] = #{attribute_to_ruby(value)}; "
      end.join
      "<% scope.new_scope { #{assigns}#{tag_newlines(el)} %>#{children_to_erb(el)}<% } %>"
    end
    
    
    def declared_attributes(def_element)
      attrspec = def_element.attributes["attrs"]
      attr_names = attrspec ? attrspec.split(/\s*,\s*/).every(:to_sym) : []
      invalids = attr_names & ([:with, :field, :this] + SPECIAL_ATTRIBUTES.every(:to_sym))
      dryml_exception("invalid attrs in def: #{invalids * ', '}", def_element) unless invalids.empty?
      attr_names
    end


    def def_element(el)
      require_toplevel(el)
      require_attribute(el, "tag", DRYML_NAME_RX)
      require_attribute(el, "attrs", /^\s*#{DRYML_NAME}(\s*,\s*#{DRYML_NAME})*\s*$/, true)
      require_attribute(el, "alias_of", DRYML_NAME_RX, true)
      require_attribute(el, "extend_with", DRYML_NAME_RX, true)
      
      unsafe_name = el.attributes["tag"]
      name = Hobo::Dryml.unreserve(unsafe_name)
      if (for_type = el.attributes['for'])
        type_name = if for_type =~ /^[a-z]/
                      # It's a symbolic type name - look up the Ruby type name
                      Hobo.field_types[for_type].name
                    else
                      for_type
                    end.underscore.gsub('/', '__')
        suffix = "__for_#{type_name}"
        name        += suffix
        unsafe_name += suffix
      end
      
      # While processing this def, @def_name contains
      # the names of all nested defs join with '_'. It's used to
      # disambiguate local variables as a workaround for the broken
      # scope semantics of Ruby 1.8.
      old_def_name = @def_name
      @def_name = @def_name ? "#{@def_name}_#{unsafe_name}" : unsafe_name

      alias_of = el.attributes['alias_of']
      extend_with = el.attributes['extend_with']

      dryml_exception("def cannot have both alias_of and extend_with", el) if alias_of && extend_with
      dryml_exception("def with alias_of must be empty", el) if alias_of and el.size > 0
      
      
      @builder.add_build_instruction(:alias_method,
                                     :new => name.to_sym, :old => alias_of.to_sym) if alias_of
      
      res = if alias_of
              "<% #{tag_newlines(el)} %>"
            else
              src = ""
              if extend_with
                src << "<% _alias_tag_chain :#{name}, :#{extend_with} %>"
                name = extended_name(name, extend_with)
              end
              src << if template_name?(name)
                       template_method(name, el)
                     else
                       tag_method(name, el)
                     end
              src << "<% _register_tag_attrs(:#{name}, #{declared_attributes(el).inspect}) %>"
              
              logger.debug(restore_erb_scriptlets(src)) if el.attributes["debug_source"]
              
              @builder.add_build_instruction(:def,
                                             :src => restore_erb_scriptlets(src),
                                             :line_num => element_line_num(el))
              # keep line numbers matching up
              "<% #{"\n" * src.count("\n")} %>"
            end
      @def_name = old_def_name
      res
    end
    
    
    def extended_name(name, feature)
      if template_name?(name)
        "#{name}With#{feature.camelize}"
      else
        "#{name}_with_#{feature}"
      end
    end
    
    
    def template_call?(el)
      template_name?(el.dryml_name)
    end
    
    
    def template_name?(name)
      name =~ /^[A-Z]/
    end
    
    
    def param_names_in_template(el)
      REXML::XPath.match(el, ".//*[@param]").map do |e|
        name = get_param_name(e)
        dryml_exception("invalid param name: #{name.inspect}", e) unless 
          is_code_attribute?(name) || name =~ DRYML_NAME_RX || name =~ /#\{/
        name.to_sym unless is_code_attribute?(name)
      end.compact
    end
    
    
    def template_method(name, el)
      param_names = param_names_in_template(el)
      
      "<% def #{name}(all_attributes={}, all_parameters={}, &__block__); " +
        "parameters = all_parameters - #{param_names.inspect}; " +
        tag_method_body(el) +
        "; end %>"
    end
    
    
    def tag_method(name, el)
      "<% def #{name}(all_attributes={}, &__block__); " +
        "parameters = nil; " +
        tag_method_body(el) + 
        "; end %>"
    end
              
    
    def tag_method_body(el, attributes_var="all_attributes", block_var="__block__")
      attrs = declared_attributes(el)
      
      # A statement to assign values to local variables named after the tag's attrs
      # The trailing comma on `attributes` is supposed to be there!
      setup_locals = attrs.map{|a| "#{Hobo::Dryml.unreserve(a)}, "}.join + "attributes, = " +
        "_tag_locals(#{attributes_var}, #{attrs.inspect})"

      start = "_tag_context(#{attributes_var}, #{block_var}) do |tagbody| #{setup_locals}"
      
      "#{start} " +
        # reproduce any line breaks in the start-tag so that line numbers are preserved
        tag_newlines(el) + "%>" +
        children_to_erb(el) +
        "<% _erbout; end"
    end
    
    
    def tagbody_element(el)
      dryml_exception("tagbody can only appear inside a <def>", el) unless
        find_ancestor(el) {|e| e.name == 'def'}
      dryml_exception("tagbody cannot appear inside a part", el) if
        find_ancestor(el) {|e| e.attributes['part']}
      tagbody_call(el)
    end
    

    def tagbody_call(el)
      attributes = []
      with = el.attributes['with']
      field = el.attributes['field']
      attributes << ":with => #{attribute_to_ruby(with)}" if with
      attributes << ":field => #{attribute_to_ruby(field)}" if field
      
      default_body = if el.children.empty?
                       "nil"
                     else
                       "proc { %>#{children_to_erb(el)}<% }"
                     end
      
      call = apply_control_attributes("do_tagbody(tagbody, {#{attributes * ', '}}, #{default_body})", el)
      "<% _output(#{call}) %>"
    end

    
    def default_tagbody_element(el)
      name = el.attributes['for'] || @containing_tag_name
      local_name = default_tagbody_name(name)
      "<% #{local_name} && #{local_name}.call %>"
    end


    def part_element(el, content)
      require_attribute(el, "part", DRYML_NAME_RX)
      part_name  = el.attributes['part']
      dom_id = el.attributes['id'] || part_name
      
      part_locals = el.attributes["part_locals"]
      
      part_src = "<% def #{part_name}_part(#{part_locals._?.gsub('@', '')}) #{tag_newlines(el)}; new_context do %>" +
        content +
        "<% end; end %>"
      @builder.add_part(part_name, restore_erb_scriptlets(part_src), element_line_num(el))

      newlines = "\n" * part_src.count("\n")
      args = [attribute_to_ruby(dom_id), ":#{part_name}", "nil", part_locals].compact
      "<%= call_part(#{args * ', '}) #{newlines} %>"
    end
    
    
    def get_param_name(el)
      param_name = el.attributes["param"]
      
      if param_name
        def_tag = find_ancestor(el) {|e| e.name == "def"}
        dryml_exception("param is not allowed outside of template definitions", el) if
          def_tag.nil? || !template_name?(def_tag.attributes["tag"])
      end
      
      res = param_name == "&true" ? el.dryml_name : param_name

      dryml_exception("param '#{res}' is for a template call must be capitalised", el) if
        res && template_call?(el) && !template_name?(res)
      dryml_exception("param '#{res}' is for a block-tag call and must not be capitalised", el) if
        res && !template_call?(el) && template_name?(res)
      
      res
    end
    
    
    def call_name(el)
      Hobo::Dryml.unreserve(el.dryml_name)
    end

   
    def polymorphic_call_type(el)
      t = el.attributes['for_type']
      if t.nil?
        nil
      elsif t == "&true"
        'this_type'
      elsif t =~ /^[A-Z]/
        t
      elsif t =~ /^[a-z]/
        "Hobo.field_types[:#{t}]"
      elsif is_code_attribute?(t)
        t[1..-1]
      else
        dryml_exception("invalid for_type attribute", el)
      end
    end
    
    
    def template_call(el)
      name = call_name(el)
      param_name = get_param_name(el)
      attributes = tag_attributes(el)
      newlines = tag_newlines(el)
      
      parameters = tag_newlines(el) + tag_parameters(el)
      
      is_param_default_call = el.attributes['restore']
      
      call = if param_name
               param_name = attribute_to_ruby(param_name, :symbolize => true)
               args = "#{attributes}, #{parameters}, all_parameters[#{param_name}]"
               to_call = if is_param_default_call
                           # The tag is available in a local variable
                           # holding a proc
                           name
                         elsif (call_type = polymorphic_call_type(el))
                           "find_polymorphic_template(:#{name}, #{call_type})"
                         else
                           ":#{name}"
                         end
               "call_template_parameter(#{to_call}, #{args})"
             else
               if is_param_default_call
                 # The tag is a proc available in a local variable
                 "#{default_parameter_name(name)}.call(#{attributes}, #{parameters})"
               elsif (call_type = polymorphic_call_type(el))
                 "send(find_polymorphic_template(:#{name}, #{call_type}), #{attributes}, #{parameters})"
               else
                 "#{name}(#{attributes}, #{parameters})"
               end
             end

      call = apply_control_attributes(call, el)
      maybe_make_part_call(el, "<% _output(#{call}) %>")
    end
    
    
    def merge_attribute(el)
      merge = el.attributes['merge']
      dryml_exception("merge cannot have a RHS", el) if merge && merge != "&true"
      merge
    end
    

    # Tag parameters are parameters to templates.
    def tag_parameters(el)
      dryml_exception("content is not allowed directly inside template calls", el) if 
        el.children.find { |e| e.is_a?(REXML::Text) && !e.to_s.blank? }

      param_items = el.map do |node|
        case node
        when REXML::Text
          # Just whitespace
          node.to_s
        when REXML::Element
          e = node
          param_name = get_param_name(e)
          if param_name
            if template_call?(e)
              ":#{e.name} => merge_template_parameter(#{template_proc(e)}, all_parameters[:#{param_name}]), "
            else
              ":#{e.name} => merge_block_tag_parameter(#{template_proc(e)}, all_parameters[:#{param_name}]), "
            end
          else
            ":#{e.name} => #{template_proc(e)}, "
          end
        end
      end.join
      
      
      merge_params = el.attributes['merge_params'] || merge_attribute(el)
      if merge_params
        extra_params = if merge_params == "&true"
                         "parameters"
                        elsif is_code_attribute?(merge_params)
                          merge_params[1..-1]
                        else
                          dryml_exception("invalid merge_params", el)
                        end
        "{#{param_items}}.merge((#{extra_params}) || {})"
      else
        "{#{param_items}}"
      end
    end

    
    def template_proc(el)
      nl = tag_newlines(el)
      if (repl = el.attribute("replace"))
        dryml_exception("replace attribute must not have a value", el) if repl.has_rhs?
        dryml_exception("replace parameters must not have attributes", el) if el.attributes.length > 1
        
        "proc {|#{default_parameter_name(el.dryml_name)}| new_context { %>#{children_to_erb(el)}<% } #{nl}}"
      else
        attributes = el.attributes.map do 
          |name, value| ":#{name} => #{attribute_to_ruby(value, el)}" unless name.in?(SPECIAL_ATTRIBUTES)
        end.compact
      
        if template_call?(el || modifiers.first)
          parameters = el ? tag_parameters(el) : "{}"
          "proc { [{#{attributes * ', '}}, #{parameters}] #{nl}}"
        else
          if el && el.has_end_tag?
            old = @containing_tag_name
            @containing_tag_name = el.dryml_name
            body = children_to_erb(el)
            @containing_tag_name = old

            attributes << ":tagbody => proc {|#{default_tagbody_name(el.dryml_name)}| new_context { %>#{body}<% } } " 
          end
          "proc { {#{attributes * ', '}} #{nl}}"
        end
      end
    end
    
    
    def default_parameter_name(name)
      "_#{name}__default"
    end
    
    
    def default_tagbody_name(name)
      "_#{name}_default_tagbody"
    end
    
    
    def tag_call(el)
      name = call_name(el)
      param_name = get_param_name(el)
      attributes = tag_attributes(el)
      newlines = tag_newlines(el)
      
      is_param_default_call = el.attributes['restore']

      call = if param_name
               to_call = if is_param_default_call
                           # The tag is available in a local variable
                           # holding a proc
                           name
                         elsif (call_type = polymorphic_call_type(el))
                           "find_polymorphic_tag(:#{name}, #{call_type})"
                         else
                           ":#{name}"
                         end
               param_name = attribute_to_ruby(param_name, :symbolize => true)
               "call_block_tag_parameter(#{to_call}, #{attributes}, all_parameters[#{param_name}])"
             else
               if is_param_default_call
                 "#{default_parameter_name(name)}.call_with_block(#{attributes})"
               elsif (call_type = polymorphic_call_type(el))
                 "send(find_polymorphic_tag(:#{name}, #{call_type}), #{attributes})"
               else
                 "#{name}(#{attributes unless attributes == '{}'})"
               end
             end
      
      if el.children.empty?
        call = apply_control_attributes(call, el)
        maybe_make_part_call(el, "<%= #{call} #{newlines}%>")
      else
        old = @containing_tag_name
        @containing_tag_name = el.dryml_name
        children = children_to_erb(el)
        @containing_tag_name = old
        
        call_statement = "#{call} do |#{default_tagbody_name(el.dryml_name)}| #{newlines}%>#{children}<% end"
        call = "<% _output(" + apply_control_attributes(call_statement, el) + ") %>"
        maybe_make_part_call(el, call)
      end
    end
    
    def maybe_make_part_call(el, call)
      part_name = el.attributes['part']
      if part_name
        part_id = part_name && "<%= #{attribute_to_ruby(el.attributes['id'] || part_name)} %>"
        "<span class='part_wrapper' id='#{part_id}'>" + part_element(el, call) + "</span>"
      else
        call
      end
    end
    
    
    def tag_attributes(el)
      attributes = el.attributes
      items = attributes.map do |n,v|
        ":#{n} => #{attribute_to_ruby(v)}" unless n.in?(SPECIAL_ATTRIBUTES)
      end.compact
      
      # if there's a ':' el.name is just the part after the ':'
      items << ":field => \"#{el.name}\"" if el.name != el.expanded_name
      
      items = items.join(", ")
      
      merge_attrs = attributes['merge_attrs'] || merge_attribute(el)
      if merge_attrs
        extra_attributes = if merge_attrs == "&true"
                          "attributes"
                        elsif is_code_attribute?(merge_attrs)
                          merge_attrs[1..-1]
                        else
                          dryml_exception("invalid merge_attrs", el)
                        end
        "merge_attrs({#{items}},(#{extra_attributes}) || {})"
      else
        "{#{items}}"
      end
    end

    def static_tag_to_method_call(el)
      part = el.attributes["part"]
      attrs = el.attributes.map do |n, v|
        next if n.in? SPECIAL_ATTRIBUTES
        val = restore_erb_scriptlets(v).gsub('"', '\"').gsub(/<%=(.*?)%>/, '#{\1}')
        %(:#{n} => "#{val}")
      end.compact
      
      # If there's a part but no id, the id defaults to the part name
      if part && !el.attributes["id"]
        attrs << ":id => '#{part}'"
      end
      
      # Convert the attributes hash to a call to merge_attrs if
      # there's a merge_attrs attribute
      attrs = if (merge_attrs = el.attributes['merge_attrs'])
                dryml_exception("merge_attrs was given a string", el) unless is_code_attribute?(merge_attrs)
        
                "merge_attrs({#{attrs * ', '}}, " +
                  "((__merge_attrs__ = (#{merge_attrs[1..-1]})) == true ? attributes : __merge_attrs__))"
              else
                "{" + attrs.join(', ') + "}"
              end
      
      if el.children.empty?
        dryml_exception("part attribute on empty static tag", el) if part

        "<%= " + apply_control_attributes("tag(:#{el.name}, #{attrs} #{tag_newlines(el)})", el) + " %>"
      else
        if part
          body = part_element(el, children_to_erb(el))
        else
          body = children_to_erb(el)               
        end

        output_tag = "tag(:#{el.name}, #{attrs}, true) + new_context { %>#{body}</#{el.name}><% }"
        "<% _output(" + apply_control_attributes(output_tag, el) + ") %>"
      end
    end
    
    
    def static_element_to_erb(el)
      if %w(part merge_attrs if unless repeat).any? {|x| el.attributes[x]}
        static_tag_to_method_call(el)
      else
        start_tag_src = el.start_tag_source.gsub(REXML::CData::START, "").gsub(REXML::CData::STOP, "")
        
        # Allow #{...} as an alternate to <%= ... %>
        start_tag_src.gsub!(/=\s*('.*?'|".*?")/) do |s|
          s.gsub(/#\{(.*?)\}/, '<%= \1 %>')
        end

        if el.has_end_tag?
          start_tag_src + children_to_erb(el) + "</#{el.name}>"
        else
          start_tag_src
        end
      end
    end
    
    
    def apply_control_attributes(expression, el)
      if_, unless_, repeat = controls = %w(if unless repeat).map {|x| el.attributes[x]}
      controls.compact!
      
      dryml_exception("You can't have multiple control attributes on the same element", el) if
        controls.length > 1
      
      val = controls.first
      if val.nil?
        expression
      else
        control = if repeat && val == "&true"
                    "this"
                  elsif is_code_attribute?(val)
                    "#{val[1..-1]}"
                  else
                    "this.#{val}"
                  end
        
        x = gensym
        if if_
          "(if !(#{control}).blank?; (#{x} = #{expression}; Hobo::Dryml.last_if = true; #{x}) " +
            "else (Hobo::Dryml.last_if = false; ''); end)"
        elsif unless_
          "(if (#{control}).blank?; (#{x} = #{expression}; Hobo::Dryml.last_if = true; #{x}) " +
            "else (Hobo::Dryml.last_if = false; ''); end)"
        elsif repeat
          "repeat_attribute(#{control}) { #{expression} }"
        end
      end
    end
    

    def attribute_to_ruby(*args)
      options = extract_options_from_args!(args)
      attr, el = args
      
      dryml_exception('erb scriptlet not allowed in this attribute (use #{ ... } instead)', el) if
        attr.is_a?(String) && attr.index("[![HOBO-ERB")

      if options[:symbolize] && attr =~ /^[a-zA-Z_][^a-zA-Z0-9_]*[\?!]?/
        ":#{attr}"
      else
        res = if attr.nil?
                "nil"
              elsif is_code_attribute?(attr)
                "(#{attr[1..-1]})"
              else
                if attr !~ /"/
                  '"' + attr + '"'
                elsif attr !~ /'/
                  "'#{attr}'"
                else
                  dryml_exception("invalid quote(s) in attribute value")
                end
                #attr.starts_with?("++") ? "attr_extension(#{str})" : str
              end 
        options[:symbolize] ? (res + ".to_sym") : res
      end
    end

    def find_ancestor(el)
      e = el.parent
      until e.is_a? REXML::Document
        return e if yield(e)
        e = e.parent
      end
      return nil
    end

    def require_toplevel(el, message=nil)
      message ||= "can only be at the top level"
      dryml_exception("<#{el.dryml_name}> #{message}", el) if el.parent != @doc.root
    end

    def require_attribute(el, name, rx=nil, optional=false)
      val = el.attributes[name]
      if val
        dryml_exception("invalid #{name}=\"#{val}\" attribute on <#{el.dryml_name}>", el) unless rx && val =~ rx
      else
        dryml_exception("missing #{name} attribute on <#{el.dryml_name}>", el) unless optional
      end
    end

    def dryml_exception(message, el=nil)
      el ||= @last_element
      raise DrymlException.new(message, template_path, element_line_num(el))
    end

    def element_line_num(el)
      offset = el.source_offset
      line_no = @xmlsrc[0..offset].count("\n") + 1
    end

    def tag_newlines(el)
      src = el.start_tag_source
      "\n" * src.count("\n")
    end

    def is_code_attribute?(attr_value)
      attr_value =~ /^\&/ && attr_value !~ /^\&\S+;/
    end

    def logger
      ActionController::Base.logger rescue nil
    end
    
    def gensym(name="__tmp")
      @gensym_counter ||= 0
      @gensym_counter += 1
      "#{name}_#{@gensym_counter}"
    end

  end

end
