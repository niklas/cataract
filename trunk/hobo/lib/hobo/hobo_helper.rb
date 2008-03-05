module Hobo
  
  module HoboHelper
  
    def self.add_to_controller(controller)
      controller.send(:include, self)
      controller.hide_action(self.instance_methods)
    end
     
    protected
     
    def current_user
      # simple one-hit-per-request cache
      @current_user ||= begin
                          id = session._?[:user]
                          (id && Hobo.object_from_dom_id(id) rescue nil) || ::Guest.new
                        end
    end
     
     
    def logged_in?
      !current_user.guest?
    end
      
      
    def base_url
      request.relative_url_root
    end
     
     
    def controller_for(obj)
      if obj.is_a? Class
        obj.name.underscore.pluralize
      else
        obj.class.name.underscore.pluralize
      end
    end
    
    
    def subsite
      params[:controller].match(/([^\/]+)\//)._?[1]
    end
     
     
    def object_url(*args)
      params = args.extract_options!
      obj, action = args
      action &&= action.to_s
      
      controller_name = controller_for(obj)
      
      subsite = params[:subsite] || self.subsite
      
      # TODO - what if you want if_available as a query param?
      if_available = params.delete(:if_available)
      return nil if if_available && 
        ((action.nil? && obj.respond_to?(:typed_id) && !linkable?(obj.class, :show,  :subsite => subsite)) ||
         (action.nil? && obj.is_a?(Class) &&           !linkable?(obj,       :index, :subsite => subsite)))
      
      base = subsite.blank? ? base_url : "/#{subsite}#{base_url}"
      
      parts = if obj.is_a? Class
                [base, controller_name]
                
              elsif obj.is_a? Hobo::CompositeModel
                [base, controller_name, obj.to_param]
                
              elsif obj.is_a? ActiveRecord::Base
                if obj.new_record?
                  [base, controller_name]
                else
                  raise HoboError.new("invalid object url: new for existing object") if action == "new"
     
                  klass = obj.class
                  id = if klass.id_name?
                         obj.id_name(true)
                       else
                         obj.to_param
                       end
                  
                  [base, controller_name, id]
                end
                
              elsif obj.is_a? Array    # warning - this breaks if we use `case/when Array`
                owner = obj.proxy_owner
                new_model = obj.proxy_reflection.klass
                [object_url(owner), obj.proxy_reflection.name]
                
              else
                raise HoboError.new("cannot create url for #{obj.inspect} (#{obj.class})")
              end
      url = parts.join("/")

      case action
      when nil       # do nothing
      when "destroy" then params["_method"] = "DELETE"
      when "update"  then params["_method"] = "PUT"
      else url += "/#{action}" 
      end

      params = make_params(params - [:subsite])
      params.blank? ? url : "#{url}?#{params}"
    end
     
     
    def _as_params(name, obj)
      if obj.is_a? Array
        obj.map {|x| _as_params("#{name}[]", x)}.join("&")
      elsif obj.is_a? Hash
        obj.map {|k,v| _as_params("#{name}[#{k}]", v)}.join("&")
      elsif obj.is_a? Hobo::RawJs
        "#{name}=' + #{obj} + '"
      else
        v = if obj.is_a?(ActiveRecord::Base) or obj.is_a?(Array)
              "@" + dom_id(obj)
            else
              obj.to_s.gsub("'"){"\\'"}
            end
        "#{name}=#{v}"
      end
    end
     
     
    def make_params(*hashes)
      hash = {}
      hashes.each {|h| hash.update(h) if h}
      hash.map {|k,v| _as_params(k, v)}.join("&")
    end
     
     
    def dom_id(*args)
      if args.length == 0
        Hobo.dom_id(this)
      else
        Hobo.dom_id(*args)
      end
    rescue ArgumentError
      ""
    end
    
    
    def type_id(type=nil)
      type ||= this.is_a?(Class) ? this : this_type
      type == NilClass ? "" : Hobo.type_id(type || this.class)
    end
    
    
    def type_and_field(*args)
      if args.empty?
        this_parent && this_field && "#{Hobo.type_id(this_parent.class)}_#{this_field}"
      else
        type, field = args
        "#{Hobo.type_id(type)}_#{field}"
      end
    end
     
     
    def map_this
      res = []
      empty = true
      if this.respond_to?(:each_index)
        this.each_index {|i| empty = false; new_field_context(i) { res << yield } }
      else
        this.map {|e| empty = false; new_object_context(e) { res << yield } }
      end
      Dryml.last_if = !empty
      res
    end
    alias_method :collect_this, :map_this
     
     
    def comma_split(x)
      case x
      when nil
        []
      when Symbol
        x.to_s
      when String
        x.split(/\s*[, ]\s*/)
      else
        x.compact.map{|e| comma_split(e)}.flatten
      end
    end
     
     
    def can_create?(object=nil)
      Hobo.can_create?(current_user, object || this)
    end
     
     
    def can_update?(object, new)
      Hobo.can_update?(current_user, object, new)
    end
     
     
    def can_edit?(*args)
      if args.empty?
        if this_parent && this_field
          can_edit?(this_parent, this_field)
        else
          can_edit?(this, nil)
        end
      else
        object, field = args.length == 2 ? args : [this, args.first]
        
        if !field and object.respond_to?(:proxy_reflection)
          Hobo.can_edit?(current_user, object.proxy_owner, object.proxy_reflection.name)
        else
          Hobo.can_edit?(current_user, object, field)
        end
      end
    end
     
     
    def can_delete?(object=nil)
      Hobo.can_delete?(current_user, object || this)
    end
     
     
    def can_view?(object=nil, field=nil)
      if object.nil? && field.nil?
        if this_parent && this_field
          object, field = this_parent, this_field
        else
          object = this
        end
      end
      
      if !field and object.respond_to?(:proxy_reflection)
        Hobo.can_view?(current_user, object.proxy_owner, object.proxy_reflection.name)
      else
        Hobo.can_view?(current_user, object, field)
      end
    end
     
     
    def select_viewable(collection)
      collection.select {|x| can_view?(x)}
    end
     
     
    def theme_asset(path)
      theme_path = Hobo.current_theme ? "hobothemes/#{Hobo.current_theme}/" : ""
      "#{base_url}/#{theme_path}#{path}"
    end
     
    def js_str(s)
      if s.is_a? Hobo::RawJs
        s.to_s
      else
        "'" + s.to_s.gsub("'"){"\\'"} + "'"
      end
    end
     
     
    def make_params_js(*args)
      ("'" + make_params(*args) + "'").sub(/ \+ ''$/,'')
    end
     
     
    def nl_to_br(s)
      s.to_s.gsub("\n", "<br/>") if s
    end
     
     
    def param_name_for(object, field_path)
      field_path = field_path.to_s.split(".") if field_path.is_a?(String, Symbol)
      attrs = field_path.map{|part| "[#{part.to_s.sub /\?$/, ''}]"}.join
      "#{object.class.name.underscore}#{attrs}"
    end
     
     
    def param_name_for_this(foreign_key=false)
      return "" unless form_this
      name = if foreign_key and this_type.respond_to?(:macro) and this_type.macro == :belongs_to
               param_name_for(form_this, form_field_path[0..-2] + [this_type.primary_key_name])
             else
               param_name_for(form_this, form_field_path)
             end
      register_form_field(name)
      name
    end
     
     
    def selector_type
      if this.is_a? ActiveRecord::Base
        this.class
      elsif this.respond_to? :member_class
        this.member_class
      elsif this == @this
        @model
      end
    end
     
     
    def transpose_with_field(field, collection=nil)
      collection ||= this
      matrix = collection.map {|obj| obj.send(field) }
      max_length = matrix.every(:length).max
      matrix = matrix.map do |a|
        a + [nil] * (max_length - a.length)
      end
      matrix.transpose
    end
     
     
    def new_for_current_user(model_or_assoc=nil)
      model_or_assoc ||= this
      record = model_or_assoc.new
      record.set_creator(current_user)
      record
    end
    
    
    def defined_route?(r)
      @view.respond_to?("#{r}_url")
    end
     
     
    # Login url for a given user record or user class
    def login_url(user_or_class)
      c = user_or_class.is_a?(Class) ? user_or_class : user_or_class.class
      send("#{c.name.underscore}_login_url") rescue nil
    end
    

    # Login url for a given user record or user class
    def logout_url(user_or_class=nil)
      c = if user_or_class.nil?
            current_user.class
          elsif user_or_class.is_a?(Class)
            user_or_class
          else
            user_or_class.class
          end
      send("#{c.name.underscore}_logout_url") rescue nil
    end
    

    # Sign-up url for a given user record or user class
    def signup_url(user_or_class)
      c = user_or_class.is_a?(Class) ? user_or_class : user_or_class.class
      send("#{c.name.underscore}_signup_url") rescue nil
    end
    
    def current_page_url
      request.request_uri.match(/^([^?]*)/)._?[1]
    end

    def query_params
      query = request.request_uri.match(/(?:\?(.+))/)._?[1]
      if query
        params = query.split('&')
        pairs = params.map do |param|
          pair = param.split('=')
          pair.length == 1 ? pair + [''] : pair
        end
        HashWithIndifferentAccess[*pairs.flatten]
      else
        HashWithIndifferentAccess.new
      end
    end
    
    def linkable?(*args)
      options = args.extract_options!
      target = args.empty? || args.first.is_a?(Symbol) ? this : args.shift
      action = args.first

      if target.is_a?(Class)
        klass = target
        action ||= :index
      elsif target.respond_to?(:member_class)
        klass = target.member_class
        action ||= :show
      else
        klass = target.class
        action ||= :show
      end      
      
      Hobo::ModelRouter.linkable?(subsite, klass, action.to_sym)
    end
   
    
    # Convenience helper for the default app
    
    def front_models
      Hobo.models.select {|m| linkable?(m) && !(m < Hobo::User)}
    end
    
    
    
    # debugging support
     
    def abort_with(*args)
      raise args.map{|arg| PP.pp(arg, "")}.join("-------\n")
    end
     
    def log_debug(*args)
      logger.debug("\n### DRYML Debug ###")
      logger.debug(args.map {|a| PP.pp(a, "")}.join("-------\n"))
      logger.debug("DRYML THIS = #{Hobo.dom_id(this) rescue this.inspect}")
      logger.debug("###################\n")
      args.first unless args.empty?
    end
    
  end

end
