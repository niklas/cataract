module Hobo

  module ModelController

    include Hobo::Controller

    class PermissionDeniedError < RuntimeError; end
    class UserPermissionError < StandardError
      attr :models
      def initialize(models)
        @models = models || []
      end
    end
    
    VIEWLIB_DIR = "taglibs"
    
    PAGINATE_FORMATS = [ Mime::HTML, Mime::ALL ]

    class << self

      def included(base)
        base.class_eval do 
          @auto_actions ||= {}
          
          extend ClassMethods
          helper_method :find_partial, :model, :current_user
          before_filter :set_no_cache_headers
        end

        Hobo::Controller.included_in_class(base)
      end

      def find_partial(klass, as)
        find_model_template(klass, as, :is_parital => true)
      end


      def template_path(dir, name, is_partial)
        fileRx = is_partial ? /^_#{name}\.[^.]+/ : /^#{name}\.[^.]+/
        full_dir = "#{RAILS_ROOT}/app/views/#{dir}"
        if File.exists?(full_dir) && Dir.entries(full_dir).grep(fileRx).any?
          return "#{dir}/#{name}"
        end
      end


      def find_model_template(klass, name, options={})
        while klass and klass != ActiveRecord::Base
          dir = klass.name.underscore.pluralize
          dir = File.join(options[:subsite], dir) if options[:subsite]
          path = template_path(dir, name, options[:is_partial])
          return path if path

          klass = klass.superclass
        end
        nil
      end
      
    end

    module ClassMethods

      attr_writer :model
      
      def add_collection_actions(name)
        defined_methods = instance_methods
        
        show_collection_method = "show_#{name}".to_sym
        if show_collection_method.not_in?(defined_methods) && include_action?(show_collection_method, true)
          define_method show_collection_method do
            hobo_show_collection(name)
          end
        end
          
        if Hobo.simple_has_many_association?(model.reflections[name])
          new_method = "new_#{name.to_s.singularize}"
          if new_method.not_in?(defined_methods) && include_action?(new_method, true)
            define_method new_method do
              hobo_new_in_collection(name)
            end
          end
        end
      end
            
      def web_methods
        @web_methods ||= superclass.respond_to?(:web_methods) ? superclass.web_methods : []
      end
      
      def show_actions
        @show_actions ||= superclass.respond_to?(:show_actions) ? superclass.show_actions : []
      end
      
      def index_actions
        @index_actions ||= superclass.respond_to?(:index_actions) ? superclass.index_actions : []
      end
      
      def collections
        # By default, all has_many associations are published
        @collections ||= if superclass.respond_to?(:collections)
                           superclass.collections
                         else
                           model.reflections.values.map {|r| r.name if r.macro == :has_many}.compact
                         end
      end

      def model
        @model ||= name.sub(/Controller$/, "").singularize.constantize
      end


      def autocomplete_for(attr, options={}, &b)
        options = options.reverse_merge(:limit => 15)
        options[:data_filters_block] = b
        @completers ||= HashWithIndifferentAccess.new
        @completers[attr.to_sym] = opts
      end


      def autocompleter(name)
        (@completers && @completers[name]) ||
          (superclass.respond_to?(:autocompleter) && superclass.autocompleter(name))
      end
      
      
      def web_method(web_name, options={}, &block)
        web_methods << web_name.to_sym
        method = options[:method] || web_name
        got_block = block_given?
        define_method web_name do
          # Make sure we have a copy of the options - it is being mutated somewhere
          opts = {}.merge(options)
          @this = find_instance(opts) unless opts[:no_find]
          permission_denied unless Hobo.can_call?(current_user, @this, method)
          if got_block
            instance_eval(&block)
          else
            @this.send(method)
          end
          hobo_ajax_response unless performed?
        end
      end
      
      
      def auto_actions(*args)
        # auto_actions is either an array - the actions to provide, or a hash: { :except => [...] }
        @auto_actions = case args.first
                          when :all  then args.extract_options!
                          when :none then []
                          else args
                        end

        self.class_eval do
          def index;   hobo_index   end if include_action?(:index) 
          def show;    hobo_show    end if include_action?(:show) 
          def new;     hobo_new     end if include_action?(:new) 
          def create;  hobo_create  end if include_action?(:create) 
          def edit;    hobo_edit    end if include_action?(:edit) 
          def update;  hobo_update  end if include_action?(:update) 
          def destroy; hobo_destroy end if include_action?(:destroy) 
          
          def completions; hobo_completions end if include_action?(:completions)
          
          collections.each { |c| add_collection_actions(c.to_sym) } 
        end
      end
      
      
      def show_action(*names, &block)
        show_actions.concat(names)
        for name in names
          if block
            define_method(name, &block)
          else
            define_method(name) { hobo_show }
          end
        end
      end
      
      def index_action(*names, &block)
        index_actions.concat(names)
        for name in names
          if block
            define_method(name, &block)
          else
            define_method(name) { hobo_index }
          end
        end
      end
      
      def publish_collection(*names)
        collections.concat(names)
        names.each {|n| add_collection_actions(n)}
      end
      
      
      def find_instance(id, options={})
        if model.id_name? and id !~ /^\d+$/
          model.find_by_id_name(id, options)
        else
          model.find(id, options)
        end
      end
            
      def include_action?(name, collection_action=false)
        name = name.to_sym
        if @auto_actions.is_a?(Array)
          # White list
          name.in?(@auto_actions) || (collection_action && :collections.in?(@auto_actions))
        else
          # Black list
          except = Array(@auto_actions[:except])
          name.not_in?(except) || (collection_action && :collections.not_in?(except))
        end
      end

    end
    

    protected
    
    def data_filter(name, &b)
      @data_filters ||= HashWithIndifferentAccess.new
      @data_filters[name] = b
    end
    
    def search(*args)
      if args.first.is_a?(Class)
        model, search_string, *columns = args
      else
        model = self.model
        search_string, *columns = args
      end
      return nil if search_string.blank?
      
      model.conditions do
        words = search_string.split
        terms = words.map do |word|
          cols = columns.map do |c|
            if c.is_a?(Symbol)
              send("#{c}_contains", word)
            elsif c.is_a?(Hash)
              c.map do |k, v| 
                related = send(k)
                v = [v] unless v.is_a?(Array)
                v.map { |related_col| related.send("#{related_col}_contains", word) }
              end
            end
          end.flatten
          any?(*cols)
        end
        all?(*terms)
      end
    end
    
    attr_accessor :data_filters
    

    # --- Action implementation helpers --- #
    
    def find_instance(*args)
      options = args.extract_options!
      res = self.class.find_instance(args.first || params[:id], options)
      instance_variable_set("@#{model.name.underscore}", res)
      res
    end
    
    
    def set_named_this!
      instance_variable_set("@#{@this.class.name.underscore}", @this)      
    end

    
    def response_block(&b)
      if b
        if b.arity == 1
          respond_to {|wants| yield(wants) }
        else
          yield
        end
        performed?
      end
    end

    
    def paginated_find(*args, &b)
      options = args.extract_options!
      filter_conditions = data_filter_conditions
      conditions_proc = if b && filter_conditions
                          proc { block(b) & block(filter_conditions) }
                        else
                          b || filter_conditions
                        end
      
      @association = options.delete(:association) ||
        if args.length == 1
          scopes = args.first
          @association = scopes.to_s.split(".").inject(model) { |m, name| m.send(name) }
        elsif args.length == 2
          owner, collection_name = args
          @association = collection_name.to_s.split(".").inject(owner) { |m, name| m.send(name) }
        end
      @reflection = @association.proxy_reflection if @association._?.respond_to?(:proxy_reflection)
      
      model_or_assoc, @member_class = if @association
                                        [@association, @association.member_class]
                                      else
                                        [model, model]
                                      end

      page_size = options.delete(:page_size) || 20
      page = options.delete(:page) || params[:page]
      
      paginate = options.fetch(:paginate, request.format.in?(PAGINATE_FORMATS))
      options.delete(:paginate)
      if paginate
        total_number = options.delete(:total_number) ||
          begin
            # If there is a conditions block, it may depend on the includes
            count_options = conditions_proc ? { :include => options[:include] } : {}
            model_or_assoc.count(count_options, &conditions_proc)
          end
        
        @pages = ::ActionController::Pagination::Paginator.new(self, total_number, page_size, page)

        options = options.reverse_merge(:limit  => @pages.items_per_page,
                                        :offset => @pages.current.offset)
      end
      
      unless options.has_key?(:order)
        _, desc, field = *params[:sort]._?.match(/^(-)?([a-z_]+(?:\.[a-z_]+)?)$/)
        if field
          @sort_field = field
          @sort_direction = desc ? "desc" : "asc"
          
          table, column = if field =~ /^(.*)\.(.*)$/
                            [$1.camelize.constantize.table_name, $2]
                          else
                            [@member_class.table_name, field]
                         end
          options[:order] = "#{table}.#{column} #{@sort_direction}"
        elsif !@association
          options[:order] = :default
        end
      end
      
      model_or_assoc.find(:all, options, &conditions_proc) 
    end

    
    def find_instance_or_not_found(this=nil)
      begin
        this || find_instance
      rescue ActiveRecord::RecordNotFound
        not_found
        false
      end
    end
    
    def save_and_set_status!(record, original=nil)
      can = if record.new_record?
              Hobo.can_create?(current_user, record)
            else
              Hobo.can_update?(current_user, original, record)
            end
      status = if can
                 record.save ? :valid : :invalid
               else
                 :not_allowed
               end
      set_status(status)
    end

    def set_status(status)
      @status = status
    end

    def invalid?; @status == :invalid; end
    
    def valid?; @status == :valid; end

    def not_allowed?; @status == :not_allowed; end
    
    
    def re_render_form(default_action)
      if params[:page_path]
        controller, view = Controller.controller_and_view_for(params[:page_path])
        hobo_render(view, model_for(controller))
      else
        hobo_render(default_action)
      end
    end
    
    
    def model_for(controller_name)
      "#{controller_name.camelize}Controller".constantize.model
    end
    
    
    # --- Action implementations --- #

    def hobo_index(*args, &b)
      options = args.extract_options!
      options = LazyHash.new(options)
      @model = model
      collection = args.first
      @this = if collection.blank?
                paginated_find(options)
              elsif collection.is_a?(String, Symbol)
                paginated_find(collection, options) # a scope name
              else
                collection
              end
      instance_variable_set("@#{@model.name.pluralize.underscore}", @this)
      response_block(&b) or hobo_render
    end
    

    def hobo_show(*args, &b)
      options = args.extract_options!
      options = LazyHash.new(options)
      
      @this = find_instance_or_not_found(args.first) and
        begin
          set_status(:not_allowed) unless Hobo.can_view?(current_user, @this)
          set_named_this!
          response_block(&b) or
            if not_allowed?
              permission_denied
            else
              hobo_render
            end
        end
    end


    def hobo_new(*args, &b)
      options = args.extract_options!
      options = LazyHash.new(options)
      @this = args.first || model.new
      @this.set_creator(current_user) if options.fetch(:set_creator, true)
      
      set_status(:not_allowed) unless Hobo.can_create?(current_user, @this)
      set_named_this!
      response_block(&b) or 
        if not_allowed?
          permission_denied
        else
          hobo_render
        end
    end
    

    def hobo_create(*args, &b)
      options = args.extract_options!
      options = LazyHash.new(options)
      
      @this = args.first || 
        begin
          create_model = if 'type'.in?(model.column_names) &&
                             (type_attr = params['type']) &&
                             type_attr.in?(model.send(:subclasses).every(:name))
                           type_attr.constantize
                         else
                           model
                         end
          create_model.new(params[model.name.underscore])
        end
      @this.set_creator(current_user) if options.fetch(:set_creator, true)
      save_and_set_status!(@this)
      set_named_this!
      
      flash[:notice] = "The #{model.name.titleize.downcase} was created successfully" if !request.xhr? && valid? 
      
      response_block(&b) or
        if valid?
          respond_to do |wants|
            wants.html { redirect_to(params[:after_submit] || object_url(@this)) }
            wants.js   { hobo_ajax_response || render(:text => "") }
          end
        elsif invalid?
          respond_to do |wants|
            wants.html { re_render_form(:new) }
            wants.js   { render(:status => 500,
                                :text => ("There was a problem creating that #{create_model.name}.\n" +
                                          @this.errors.full_messages.join("\n"))) }
          end
        elsif not_allowed?
          permission_denied
        end
    end
    

    def hobo_edit(*args, &b)
      hobo_show(*args, &b)
    end
    
    
    def hobo_update(*args, &b)
      options = args.extract_options!
      options = LazyHash.new(options)
      
      @this = find_instance_or_not_found(args.first) or return
      original = @this.duplicate
      # 'duplicate' can cause these to be set, but they can conflict
      # with the changes so we clear them
      @this.send(:clear_aggregation_cache)
      @this.send(:clear_association_cache)
      
      changes = params[model.name.underscore]
      @this.attributes = changes
      save_and_set_status!(@this, original)

      # Ensure current_user isn't out of date
      @current_user = @this if @this == current_user
      
      flash[:notice] = "Changes to the #{model.name.titleize.downcase} were saved" if !request.xhr? && valid?
      
      set_named_this!
      response_block(&b) or 
        if valid?
          respond_to do |wants|
            wants.html do
              redirect_to(params[:after_submit] || object_url(@this))
            end
            wants.js do
              if changes.size == 1
                # Decreasingly hacky support for the scriptaculous in-place-editor
                new_val = Hobo::Dryml.render_tag(@template, "view",
                                                 :with => @this, :field => changes.keys.first,
                                                 :no_wrapper => true)
                hobo_ajax_response(@this, :new_field_value => new_val)
              else
                hobo_ajax_response(@this)
              end
               
              # Maybe no ajax requests were made
              render :nothing => true unless performed?
            end
          end
        elsif invalid?
          respond_to do |wants|
          wants.html { re_render_form(:edit) }
            wants.js { render(:status => 500,
                              :text => ("There was a problem with that change.\n" + 
                                        @this.errors.full_messages.join("\n"))) }
          end
        elsif not_allowed?
          permission_denied
        end
    end
    
    
    def hobo_destroy(*args, &b)
      options = args.extract_options!
      options = LazyHash.new(options)
      @this = find_instance_or_not_found(args.first) or return
      
      set_named_this!

      set_status(Hobo.can_delete?(current_user, @this) ? :valid : :not_allowed)
      unless not_allowed?
        @this.destroy 
        flash[:notice] = "The #{model.name.titleize.downcase} was deleted" unless request.xhr?
      end

      response_block(&b) or
        if not_allowed?
          permission_denied
        else
          respond_to do |wants|
            wants.html { redirect_to(:action => "index") }
            wants.js   { hobo_ajax_response || render(:text => "") }
          end
        end
    end

    
    def hobo_show_collection(collection, options={}, &b)
      options = LazyHash.new(options)
      
      @owner = find_instance_or_not_found(options[:owner]) or return
      
      if collection.is_a?(Array)
        @this = collection
        @reflection = collection.proxy_reflection if collection.respond_to?(:proxy_reflection)
      else
        toplevel_collection = collection.to_s.split(".").first
        set_status(:not_allowed) unless Hobo.can_view?(current_user, @owner, toplevel_collection)
        @this = paginated_find(@owner, collection, options) unless not_allowed?
      end
      
      response_block(&b) or 
        if not_allowed?
          permission_denied
        else
          hobo_render(params[:action]) or (@reflection and hobo_render(:show_collection, @reflection.klass))
        end
    end
    
    
    def hobo_new_in_collection(collection, *args, &b)
      options = args.extract_options!
      this = args.first
      options = LazyHash.new(options)
      
      @owner = find_instance_or_not_found(options[:owner]) or return
      @association = collection.is_a?(Array) ? collection : @owner.send(collection)
      @this = this || @association.new
      set_named_this!
      @this.set_creator(current_user) if options.fetch(:set_creator, true)

      set_status(:not_allowed) unless Hobo.can_create?(current_user, @this)
      
      response_block(&b) or
        if not_allowed?
          permission_denied
        else
          hobo_render("new_#{collection.to_s.singularize}") or hobo_render("new_in_collection", @this.class)
        end
    end
    

    def hobo_completions
      opts = self.class.autocompleter(params[:for])
      if opts
        # Eval any defined filters
        instance_eval(&opts[:data_filters_block]) if opts[:data_filters_block]
        conditions = data_filter_conditions
        q = params[:query]
        items = model.find(:all) { all?(send("#{attr}_contains", q), conditions && block(conditions)) }

        render :text => "<ul>\n" + items.map {|i| "<li>#{i.send(attr)}</li>\n"}.join + "</ul>"
      else
        render :text => "No completer for #{attr}", :status => 404
      end
    end
    
    #def hobo_create_in_collection(collection, options={}, &b)
    #  hobo_create do
    #    hobo_new_in_collection(collection, :this => @this, &b)
    #  end
    #end
    
    
    # --- Response helpers --- #

    
    def permission_denied(options={})
      if respond_to? :permission_denied_response
        permission_denied_response
      elsif render_tag("PermissionDeniedPage", { :with => @this }, :status => 403)
        # cool
      else
        message = options[:message] || "Permission Denied"
        render :text => message, :status => 403
      end
    end
    
    
    def not_found
      if respond_to? :not_found_response
        not_found_response
      elsif render_tag("NotFoundPage", { :with => @this }, :status => 404)
        # cool
      else
        render(:text => "The page you requested cannot be found.", :status => 404)
      end
    end
    

    def hobo_render(page_kind = nil, page_model=nil)
      page_kind ||= params[:action].to_sym
      page_model ||= model
      
      template = ModelController.find_model_template(page_model, page_kind, :subsite => subsite)

      begin
        if template
          render :template => template
          true
        else
          # This returns false if no such tag exists
          render_tag("#{page_kind.to_s.camelize}Page", :with => @this)
        end
      rescue ActionView::TemplateError => wrapper
        e = wrapper.original_exception if wrapper.respond_to? :original_exception
        if e.is_a? Hobo::ModelController::UserPermissionError
          if current_user.guest?
            redirect_to login_url(e.models.first || UserController.user_models.first)
          else
            permission_denied(:message => e.message)
          end
        else
          raise
        end
      end
    end

    
    # --- filters --- #
    
    def set_no_cache_headers
      headers["Pragma"] = "no-cache"
      #headers["Cache-Control"] = ["must-revalidate", "no-cache", "no-store"]
      #headers["Cache-Control"] = "no-cache"
      headers["Cache-Control"] = "no-store"
      headers["Expires"] ='0'
    end

    # --- end filters --- #
    

    def model
      self.class.model
    end
    

    def data_filter_conditions
      active_filters = data_filters && (params.keys & data_filters.keys)
      filters = data_filters
      params = self.params
      proc do
        all?(*active_filters.map {|f| instance_exec(params[f], &filters[f])})
      end unless active_filters.blank?
    end
    
  end

end
