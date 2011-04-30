module OhBehave
  module BehaviourCaching

    def self.included(base)
      base.extend ControllerClassMethods
    end

    def cached_behaviours
      @cached_behaviours ||= OhBehave::BehaviourScript.new()
    end

    module ControllerClassMethods

      def caches_behaviour(*action)
        actions.each do |action|
          class_eval "prepend_before_filter { |c| c.cache_behaviours = (c.action_name == '#{action}') }"
        end
      end

      def caches_page(*actions)
        caches_behaviour(*actions)
        super
      end

      def caches_action(*actions)
        caches_behaviour(*actions)
        super
      end

    end

    def expire_behaviour(options={ })
      if OhBehave::Configuration.dynamic_path
        self.class.expire_page "#{OhBehave::Configuration.dynamic_path}#{url_for(options)}.js"
      end
    end

    def expire_page(options={ })
      expire_behaviour(options)
      super
    end

    def expire_action(options={ })
      if options[:action].is_a?(Array)
        options[:action].dup.each do |action|
          expire_behaviour(options.merge({ :action => action }))
        end
      else
        expire_behaviour(options)
      end
      super
    end

  end
end
