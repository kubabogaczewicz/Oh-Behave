module OhBehave
  module ControllerMethods
    def self.included(base)
      base.extend ControllerClassBehaviourMethods
      base.class_eval do
        before_filter :initialise_behaviours
        after_filter :store_behaviours
        after_filter :store_controller_for_helpers
      end
    end

    def cache_behaviours
      @_dynamic_behaviours.enable_cache
    end

    def apply_behaviour(selector, behaviour)
      @_dynamic_behaviours.add_behaviour(selector, behaviour)
    end

    attr_writer :behaviour_controller, :behaviour_action
    def behaviour_controller
      @behaviour_controller ||= self.controller_path
    end

    def behaviour_action
      @behaviour_action ||= self.action_name
    end

    def initialise_behaviours
      @_dynamic_behaviours = OhBehave::BehaviourScript.new
      self.class.initialise_static_behaviours
    end

    def store_behaviours
      session[:_dynamic_behaviours] = @_dynamic_behaviours.to_hash
      session[:_static_behaviours] = self.class.behaviours_for(behaviour_action)
    end

    protected
    def dynamic_behaviours
      return nil if session[:_dynamic_behaviours].nil?
      OhBehave::ScriptConverter.convert_from_hash(session[:_dynamic_behaviours])
    end

    def store_controller_for_helpers
      ActionView::Helpers.current_controller = self
    end

    public
    module ControllerClassBehaviourMethods

      def initialise_static_behaviours # :nodoc:
        behaviour :controller unless has_behaviour_rule_for? :controller
        behaviour :action unless has_behaviour_rule_for? :action
      end

      # Allows you to both define new custom behaviours that should get attached to certain actions
      # and to redeclare behaviour that gets attached to actions by default.
      #
      # :call-seq
      #   behaviour behaviour_name
      #   behaviour behaviour_name, :only|:except => ...
      #
      # As behaviour_name you can pass both a String and a Symbol. If the given parameter is a
      # Symbol then the file that defines that behaviour will be searched in behaviours folder under
      # name +"#{symbol.id2name}.bjs"+. If the name is a String then:
      #
      # * if it starts with a backslash ('\') the file is searched within the main behaviours
      #   folder
      # * otherwise it is searched starting from the folder defining behaviours for current
      #   controller,
      # * if no file extension is given in the string, then ".bjs" is considered valid one.
      #
      # There are two special forms of behaviour_name: +:controller+ means current controller and by
      # this behaviour attached to the whole controller, and +:action+ means every action and by
      # this behaviour attached by default to the action. See examples for more information.
      #
      # Second parameter is optional and declares which actions should the declared behaviour be
      # attached to. It takes standard form of a Hash with one key (either +:only+ or +:except+) and
      # a Symbol or an Array of Symbols listing action names to which behaviour should/should not be
      # attached.
      #
      # Examples:
      #   behaviour :controller, :only => :index    # will attach controller default behaviour only
      #     to action +index+. By default controller behaviour would be attached to every action.
      #   behaviour :action, :except => :save       # will stop attaching default action behaviour
      #     (that is 'controller_name/save.bjs') to action +save+
      #   behaviour :draggable                   # adds "/draggable.bjs" as a behaviour for all
      #     actions in current controller
      #   behaviour :draggable, :only => :index  # adds "/draggable.bjs" as a behaviour, but only for
      #     action +index+
      #   behaviour :draggable, :except => [:index, :show] # adds "/draggable.bjs" as a behaviour
      #     for all actions except +index+ and +show+
      #   behaviour 'draggable'                  # adds "/controller_name/draggable.bjs" as a
      #     behaviour for all actions
      #   behaviour '/draggable.bbj'             # adds '/draggable.bbj' for all actions
      #
      # Behaviours are inherited downwards, that is for example behaviours declared in application
      # controller are present in every controller in your application.
      #
      def behaviour(name, conditions = { :only => [:all] })
        name = behaviour_file(name)
        write_inheritable_hash(:static_behaviours, { name => normalize_conditions(conditions)})
      end

      def behaviours_for(action)
        _behaviours = []
        static_behaviours.each do |key, rules|
          case key
          when :controller then
            _behaviours << "/#{controller_path}.bjs" if allowed_for_action?(action, rules)
          when :action then
            _behaviours << "/#{controller_path}/#{action}.bjs" if allowed_for_action?(action, rules)
          else
            _behaviours << key if allowed_for_action?(action, rules)
          end
        end
        _behaviours
      end

      private
      def behaviour_file(name) # :nodoc:
        case name
        when :controller, :action then
          name
        when Symbol
          "/#{controller_path}/" + name.id2name + '.bjs'
        when String
          new_name = case name
                     when /^\/.*/
                       name
                     else
                       "/#{controller_path}/#{name}"
                     end
          new_name += '.bjs' if File.extname(new_name).empty?
          new_name
        end
      end

      def allowed_for_action?(action, rules)
        case
        when only = rules[:only]
          only.include?(action) || only.include?('all')
        when except = rules[:except]
          !except.include?(action) && !except.include?('all')
        end
      end

      def has_behaviour_rule_for?(behaviour_name)
        static_behaviours && static_behaviours.has_key?(behaviour_name)
      end

      def static_behaviours
        read_inheritable_attribute :static_behaviours
      end
    end
  end
end
