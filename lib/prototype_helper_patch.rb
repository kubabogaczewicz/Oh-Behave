module ActionView::Helpers::PrototypeHelper
  alias_method :core_link_to_remote, :link_to_remote

  def link_to_remote(name, options = {}, html_options = {})
    html_options[:href] ||= options[:url]
    core_link_to_remote(name, options, html_options)
  end
end
