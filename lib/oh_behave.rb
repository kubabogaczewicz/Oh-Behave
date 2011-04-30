module OhBehave
  class Configuration
    cattr_accessor :generated_id_prefix, :careful_mode, :static_path, :dynamic_path

    # Kazdy element HTML, który ma mieć podczepione zachowanie
    # javascriptowe potrzebuje posiadać atrybut id, aby móc go
    # jednoznacznie określić w dokumencie. Dlatego jeżeli dany
    # elementy nie będzie posiadał nadanego przez programistę
    # atrybutu id, zostanie mu nadany wygenerowany automatycznie
    # znacznik, postaci "#{@@generated_id_prefix}#{losowa_liczba}"
    @@generated_id_prefix = '__behaviour_'

    # Scieżka do domyślnego katalogu, w którym będą się znajdowały
    # wszystkie pliki definiujące zachowania (czyli pliki .bjs)
    # Po zmianie
    @@behaviours_path = 'app/views/behaviours'

    def self.behaviours_path
      @@_behaviours_path ||= "#{RAILS_ROOT}/#{@@behaviours_path}"
    end

    def self.behaviours_path=(new_path)
      @@_behaviours_path = nil
      @@behaviours_path  = new_path
    end

    # If set to true every defined behaviour will check if file defining behaviour exists prior to
    # using it and if the file doesn't exists it will just log it. If set to false trying to get
    # such behaviour file will end in an IOError.
    #
    # By default set to false cause in developement mode we want to know about such errors as fast
    # as possible. On the other hand in production mode it is adviced to set to false, so that
    # an error will only end in worse functionality of the site, without blocking user from using
    # the site completely.
    @@careful_mode = true

    # Prefix for the request path for static behaviours. If set to nil no routes and javascript
    # links will be generated for static behaviours effectivly turning them off.
    @@static_path = 'static_behaviours'

    # Prefix for the request path for dynamic behaviours. If set to nil no routes and javascript
    # links will be generated for dynamic behaviours effectivly turning them off.
    @@dynamic_path = 'dynamic_behaviours'

  end

  # konfiguracja pluginu
  PLUGIN_NAME = 'oh_behave'
  PLUGIN_PATH = "#{RAILS_ROOT}/vendor/plugins/#{PLUGIN_NAME}"
  PLUGIN_CONTROLLER_PATH = "#{PLUGIN_PATH}/lib/controllers"

  class << self
    # Adds routes required by the plugin to work.
    #
    # Adds paths both for dynamic and static behaviours. Will add required path
    # only if static|dynamic-path is truish (that is is not false or nil).
    # Added paths are of shape
    #   /#{static|dynamic_path}/*page_path
    def routes
      r = ActionController::Routing::Routes
      OhBehave::Configuration.static_path &&
        r.add_route("/#{OhBehave::Configuration.static_path}/*page_path",
                    :controller => 'behaviours',
                    :action => 'generate_static')
      OhBehave::Configuration.dynamic_path &&
        r.add_route("/#{OhBehave::Configuration.dynamic_path}/*page_path",
                    :controller => 'behaviours',
                    :action => 'generate_dynamic')

    end
  end
end
