module Hobo::Dryml

  class TemplateEnvironment
    
    class << self
      def inherited(subclass)
        subclass.compiled_local_names = []
      end
      attr_accessor :load_time, :compiled_local_names
           
      
      def _register_tag_attrs(tag_name, attrs)
        @tag_attrs ||= {}
        @tag_attrs[tag_name] = attrs
      end
     
      
      def tag_attrs
        @tag_attrs ||= {}
      end
      
      alias_method :_alias_tag_chain, :alias_tag_chain
      
    end

    for mod in ActionView::Helpers.constants.grep(/Helper$/).map {|m| ActionView::Helpers.const_get(m)}
      include mod
    end

    def initialize(view_name=nil, view=nil)
      unless view_name.nil? && view.nil?
        @view = view
        @_view_name = view_name
        @_erb_binding = binding
        @_part_contexts = {}
        @_scoped_variables = ScopedVariables.new

        # Make sure the "assigns" from the controller are available (instance variables)
        if view
          view.assigns.each do |key, value|
            instance_variable_set("@#{key}", value)
          end

          # copy view instance variables over
          view.instance_variables.each do |iv|
            instance_variable_set(iv, view.instance_variable_get(iv))
          end
        end
      end
    end

    attr_accessor 

    for attr in [:erb_binding, :part_contexts, :view_name,
                 :this, :this_parent, :this_field, :this_type,
                 :form_field_path, :form_this, :form_field_names]
      class_eval "def #{attr}; @_#{attr}; end"
    end
    
    
    def attrs_for(name)
      self.class.tag_attrs[name.to_sym]
    end
    
    
    def add_classes!(attributes, *classes)
      classes = classes.flatten.select{|x|x}.every(:to_s)
      current = attributes[:class]
      attributes[:class] = (current ? current.split + classes : classes).uniq.join(' ')
      attributes
    end


    def add_classes(attributes, *classes)
      add_classes!(HashWithIndifferentAccess.new(attributes), classes)
    end

    
    def merge_attrs(attrs, overriding_attrs)
      return {}.update(attrs) if overriding_attrs.nil?
      attrs = attrs.with_indifferent_access unless attrs.is_a?(HashWithIndifferentAccess)
      classes = overriding_attrs[:class]
      attrs = add_classes(attrs, *classes.split) if classes
      attrs.update(overriding_attrs - [:class])
    end
    
    
    def scope
      @_scoped_variables
    end


    def attr_extension(s)
      AttributeExtensionString.new(s)
    end

    
    def this_field_dom_id
      if this_parent && this_field
        Hobo.dom_id(this_parent, this_field)
      else
        Hobo.dom_id(this)
      end
    end

    
    def context_id
      if this_parent and this_parent.is_a?(ActiveRecord::Base) and this_field
        this_field_dom_id
      elsif this.respond_to?(:typed_id)
        this.typed_id
      elsif this.is_a?(Array) and !this.respond_to?(:proxy_reflection)
        "nil"
      else
        Hobo.dom_id(this)
      end
    end

    
    def call_part(dom_id, part_name, part_this=nil, *locals)
      res = ''
      if part_this
        new_object_context(part_this) do
          @_part_contexts[dom_id] = PartContext.new(part_name, context_id, locals)
          res = send("#{part_name}_part", *locals)
        end
      else
        new_context do
          @_part_contexts[dom_id] = PartContext.new(part_name, context_id, locals)
          res = send("#{part_name}_part", *locals)
        end
      end
      res
    end
    
    def call_polymorphic_tag(*args, &b)
      attributes = extract_options_from_args!(args)
      name, type = args
      
      tag = find_polymorphic_tag(name, type)
      if tag != name
        send(tag, attributes, &b)
      else
        nil
      end
    end

    
    def find_polymorphic_tag(name, call_type=nil)
      call_type ||= this_type
      return name if call_type.is_a?(ActiveRecord::Reflection::AssociationReflection)
      call_type = TrueClass if call_type == FalseClass

      while true
        if call_type == ActiveRecord::Base || call_type == Object
          return name
        elsif respond_to?(poly_name = "#{name}__for_#{call_type.name.to_s.underscore.gsub('/', '__')}")
          return poly_name
        else
          call_type = call_type.superclass
        end
      end
    end
    alias_method :find_polymorphic_template, :find_polymorphic_tag
    
    
    def repeat_attribute(array, &b)
      res = array.map { |x| new_object_context(x, &b) }.join
      Hobo::Dryml.last_if = !array.empty?
      res
    end

    
    def _erbout
      @_erb_output
    end
    
    
    def _output(s)
      @_erb_output.concat(s)
    end


    def new_context
      ctx = [ @_erb_output,
              @_this, @_this_parent, @_this_field, @_this_type,
              @_form_field_path]
      @_erb_output = ""
      res = yield
      @_erb_output, @_this, @_this_parent, @_this_field, @_this_type,
          @_form_field_path = ctx
      res.to_s
    end


    def new_object_context(new_this)
      new_context do
        @_this_parent,@_this_field,@_this_type = if new_this.respond_to?(:proxy_reflection)
                                                   refl = new_this.proxy_reflection
                                                   [new_this.proxy_owner, refl.name, refl]
                                                 else
                                                   # In dryml, TrueClass is the 'boolean' class
                                                   t = new_this.class == FalseClass ? TrueClass : new_this.class
                                                   [nil, nil, t]
                                                 end
        @_this = new_this
        yield
      end
    end


    def new_field_context(field_path, tag_this=nil)
      new_context do
      path = if field_path.is_a? Array
               field_path
             elsif field_path.is_a? String
               field_path.split('.')
             else
               [field_path]
             end
        parent, field, obj = Hobo.get_field_path(tag_this || this, path)

        type = if parent.class.respond_to?(:field_type) && field_type = parent.class.field_type(field)
                 field_type
               elsif obj == false
                 # In dryml, TrueClass is the 'boolean' class
                 TrueClass
               else
                 obj.class
               end
        
        @_this, @_this_parent, @_this_field, @_this_type = obj, parent, field, type
        @_form_field_path += path if @_form_field_path
        yield
      end
    end


    def _tag_context(options, tagbody_proc)
      tagbody = tagbody_proc && proc do |*args|
        res = ''
        
        block_options, default_tagbody = args
        block_with = block_options && block_options[:with]
        if block_options && block_options.has_key?(:field)
          new_field_context(block_options[:field], block_with) { res = tagbody_proc.call(default_tagbody) }
        elsif block_options && block_options.has_key?(:with)
          new_object_context(block_with) { res = tagbody_proc.call(default_tagbody) }
        else
          new_context { res = tagbody_proc.call(default_tagbody) }
        end
        res
      end
      
      with = options[:with] == "page" ? @this : options[:with]
      
      if options.has_key?(:field)
        new_field_context(options[:field], with) { yield tagbody }
      elsif options.has_key?(:with)
        new_object_context(with) { yield tagbody }
      else
        new_context { yield tagbody }
      end
    end


    def with_form_context
      @_form_this = this
      @_form_field_path = []
      @_form_field_names = []
      res = yield
      field_names = @_form_field_names
      @_form_this = @_form_field_path = @_form_field_names = nil
      [res, field_names]
    end
    
    
    def register_form_field(name)
      @_form_field_names << name
    end


    def _tag_locals(attributes, locals)
      attributes.symbolize_keys!
      #ensure with and field are not in attributes
      attributes.delete(:with)
      attributes.delete(:field)
      
      # positional arguments never appear in the attributes hash
      stripped_attributes = HashWithIndifferentAccess.new.update(attributes)
      locals.each {|a| stripped_attributes.delete(a.to_sym) }
      
      # Return locals declared as local variables (attrs="...")
      locals.map {|a| attributes[a.to_sym]} + [stripped_attributes]
    end
    
    
    def do_tagbody(tagbody, attributes, default_tagbody)
      res = if tagbody
              tagbody.call(attributes, default_tagbody)
            else
              default_tagbody ? new_context { default_tagbody.call } : ""
            end
      Hobo::Dryml.last_if = !!tagbody
      res
    end
    
    
    def call_block_tag_parameter(the_tag, attributes, overriding_proc, &default_tagbody)
      if overriding_proc && overriding_proc.arity == 1
        # This is a 'replace' parameter
        
        template_default = proc do |attrs, body_block|
          tagbody_proc = body_block && proc {|_| new_context { body_block.call(default_tagbody) } }
          call_block_tag_parameter(the_tag, attributes, proc { attrs.update(:tagbody => tagbody_proc) }, &default_tagbody)
        end
        overriding_proc.call(template_default)
      else
        if overriding_proc
          overriding_attributes = overriding_proc.call
          overriding_tagbody = overriding_attributes.delete(:tagbody)
          attributes = merge_attrs(attributes, overriding_attributes)
        end
      
        if the_tag.is_a?(String, Symbol) && the_tag.to_s.in?(Hobo.static_tags)
          body = if overriding_tagbody
                   new_context { overriding_tagbody.call(proc { default_tagbody.call(nil) }) }
                 elsif default_tagbody
                   new_context { default_tagbody.call(nil) }
                 else
                   nil
                 end
          if body.blank?
            tag(the_tag, attributes)
          else
            content_tag(the_tag, body, attributes)
          end
        else
          if the_tag.is_a?(String, Symbol)
            body = proc do |default| 
              if overriding_tagbody
                overriding_tagbody.call(proc { default_tagbody ? default_tagbody.call(default) : "" })
              else
                default_tagbody ? default_tagbody.call(default) : ""
              end
            end
            
            send(the_tag, attributes, &body)
          else
            # It's a proc - a template default
            the_tag.call(attributes, overriding_tagbody || default_tagbody)
          end
        end
      end
    end

    def call_template_parameter(the_template, attributes, template_procs, overriding_proc)
      if overriding_proc && overriding_proc.arity == 1
        # It's a replace parameter
        
        template_default = proc do |attributes, parameters|
          call_template_parameter(the_template, attributes, template_procs, proc { [attributes, parameters] })
        end
        overriding_proc.call(template_default)
      else
        if overriding_proc
          overriding_attributes, overriding_template_procs = overriding_proc.call
          
          attributes = merge_attrs(attributes, overriding_attributes)
          template_procs = template_procs.merge(overriding_template_procs)
        end   
      
        send(the_template, attributes, template_procs)
      end
    end
    
    # Takes two procs that each returh hashes and returns a single
    # proc that calls these in turn and merges the results into a
    # single hash
    def merge_block_tag_parameter(general_proc, overriding_proc)
      if overriding_proc.nil?
        general_proc
      else
        if overriding_proc.arity == 1
          # The override is a replace parameter - just pass it on
          overriding_proc
        else
          proc do 
            overriding_attrs = overriding_proc.call
            defined_attrs = general_proc.call
            
            attrs = merge_attrs(defined_attrs, overriding_attrs)
            
            # The overrider should provide its tagbody as the new
            # <default_tagbody/>
            if overriding_attrs[:tagbody] && defined_attrs[:tagbody]
              attrs[:tagbody] = proc do |default|
                overriding_attrs[:tagbody].call(proc { _output(defined_attrs[:tagbody].call(default)) })
              end
            end

            attrs
          end
        end
      end
    end
    
    # Same as merge_option_procs, except these procs return a pair of
    # hashes rather than a single hash. The first hash is the tag
    # attributes, the second is a hash of procs -- the template
    # parameters.
    def merge_template_parameter(general_proc, overriding_proc)
      proc do
        general_attributes, general_template_procs = general_proc.call
        overriding_attributes, overriding_template_procs = overriding_proc.call
        [merge_attrs(general_attributes, overriding_attributes), general_template_procs.merge(overriding_template_procs)]
      end
    end
    
    
    def part_contexts_storage_tag
      storage = part_contexts_storage
      storage.blank? ? "" : "<script>\n#{storage}</script>\n"
    end
    
    
    def part_contexts_storage
      PartContext.client_side_storage(@_part_contexts, session)
    end
    
    
    def render_tag(tag_name, attributes)
      if respond_to?(tag_name)
        (send(tag_name, attributes) + part_contexts_storage_tag).strip
      else
        false
      end
    end
    
    
    def session
      @view ? @view.session : {}
    end
    

    def method_missing(name, *args, &b)
      @view.send(name, *args, &b)
    end
    

  end
  

end
