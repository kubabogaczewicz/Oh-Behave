module OhBehave::Helpers

  # Because it can only be called by changed tag_options when it
  # sees event observer and knows it is not an xhr? call, then all it
  # has to do is to pass the behaviour to the controller
  def apply_behaviour(selector, behaviour)
    behaviour = normalise_behaviour_string(behaviour)
    @controller.apply_behaviour(selector, behaviour)
    ''
  end

  # Checks if it's a xhr call, if so behaviours should stay in the template
  def set_default_external!(options)
    options.reverse_merge!('external' => !current_controller.request.xhr?)
  end

  def normalise_behaviour_string(behaviour)
    behaviour << ';' unless behaviour =~ /;$/
    # in scripts registered via javascript return false does
    # not stop propagation - you have to do event.stop().
    # WARN: this method is dangerous, as for example
    # if (foo.bar) return false; else foo.la();
    # after the gsub has a syntax error
    # if (foo.bar) event.stop(); return false; else foo.la();
    # but it's better then nothing, and writing statement body without
    # { } is a bad and uncommon proctise after all.
    behaviour.gsub!('return false', 'event.stop(); return false')
    behaviour
  end

  def current_controller
    @controller
  end

end
