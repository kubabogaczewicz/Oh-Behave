module ActionView::Helpers::AssetTagHelper
  alias_method :core_javascript_include_tag, :javascript_include_tag

  def javascript_include_tag(*sources)
    if sources.delete :behaviours
      sources = sources.concat(['lowpro', behaviours_paths].flatten.compact).uniq
    end
    core_javascript_include_tag(*sources)
  end

  protected
  def behaviours_paths
    [behaviours_static_path, behaviours_dynamic_path]
  end

  def behaviours_static_path
    OhBehave::Configuration.static_path &&
      "/#{OhBehave::Configuration.static_path}#{behaviour_request_path}"
  end

  def behaviours_dynamic_path
    OhBehave::Configuration.dynamic_path &&
      "/#{OhBehave::Configuration.dynamic_path}#{behaviour_request_path}"
  end

  def behaviour_request_path
    case @controller.request.path
    when '', '/index', '/'
      '/index'
    else
      @controller.request.path
    end
  end
end
