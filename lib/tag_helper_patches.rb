module ActionView::Helpers::TagHelper
  include OhBehave::Helpers

  JAVASCRIPT_EVENTS = %w(click mouseup mousedown dblclick mousemove mouseover mouseout
                         submit change keypress keyup load)

  alias_method :rails_tag_options, :tag_options

  protected
  # Patch to original tag_options, checks if there are any event observers
  # and if so then makes them unobtrusive that is gives them to the controller
  # which will pass them in session to the BehavioursController.
  def tag_options(opts, escape = true)
    set_default_external!(opts)
    if opts['external']
      JAVASCRIPT_EVENTS.each do |event|
        unless opts["on#{event}"].blank?
          opts['id'] = generate_html_id unless opts['id']
          apply_behaviour("##{opts['id']}:#{event}", opts["on#{event}"]) unless opts["on#{event}"].nil?
          opts.delete("on#{event}")
        end
      end
      opts.delete('external')
    end
    rails_tag_options(opts, escape)
  end

  def generate_html_id
    @tag_counter ||= 0
    @tag_counter = @tag_counter.next
    "#{OhBehave::Configuration.generated_id_prefix}#{@tag_counter}"
  end

end
