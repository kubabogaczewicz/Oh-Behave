module OhBehave
  class BehaviourScript
    attr_reader :behaviours

    def initialize(cache = false)
      @behaviours, @cache = [], cache
    end

    def cache?
      @cache
    end

    def enable_cache
      @cache = true
    end

    def add_behaviour(selector, behaviour)
      @behaviours << [selector, behaviour]
    end

    def behaviours_js
      @behaviours.uniq.collect{ |sel, js| behaviour_rule(sel, js)}.join(",\n")
    end

    def to_hash
      OhBehave::ScriptConverter.convert_to_hash(self)
    end

    def to_s
      (@behaviours && !@behaviours.empty?) ? "Event.addBehavior({\n#{behaviours_js}\n});" : ''
    end

    protected
    def behaviour_rule(selector, behaviour)
      "\"#{selector}\": function(event) {\n#{behaviour}\n}"
    end

  end
end
