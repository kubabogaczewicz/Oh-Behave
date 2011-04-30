module ActionView::Helpers::JavaScriptHelper
  alias_method :core_link_to_function, :link_to_function

  # Making href atribute of remote links default to the same address that the xhr request goes to.
  def link_to_function(name, *args, &block)
    html_options = args.last.is_a?(Hash) ? args.pop : {}
    html_options[:href] ||= args.first# if args.first.is_a? Hash
    core_link_to_function(name, args, html_options, &block)
  end
end
