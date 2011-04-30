module OhBehave
  class ScriptConverter

    def initialize(script)
      @script = script
    end

    def self.convert_to_hash(script)
      self.new(script).to_hash
    end

    def self.convert_from_hash(script_hash)
      script = OhBehave::BehaviourScript.new(script_hash[:cache])
      script_hash[:behaviours].each { |b| script.add_behaviour(b[0], b[1])}
      script
    end

    def to_hash
      { :cache => @script.cache?, :behaviours => @script.behaviours}
    end
  end
end
