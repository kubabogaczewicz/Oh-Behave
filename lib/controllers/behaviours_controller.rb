require 'digest/md5'

class BehavioursController < ActionController::Base
  before_filter :set_content_type
  after_filter :empty_static_behaviours, :only => :generate_static
  after_filter :empty_dynamic_behaviours, :only => :generate_dynamic
  after_filter :perform_static_caching, :only => :generate_static
  after_filter :perform_dynamic_caching, :only => :generate_dynamic

  def generate_static
    static_behaviours = session[:_static_behaviours]
    static_behaviours.map! { |filepath| "#{OhBehave::Configuration.behaviours_path}#{filepath}"}
    @js_static_behaviours = collect_behaviours(static_behaviours)
    render :text => js_attach_behaviours, :layout => false
  end

  def generate_dynamic
    if dynamic_behaviours
      generate_etag(dynamic_behaviours.to_s)
      modified? ? render_dynamic_script : render_304
    else
      render :text => "", :layout => false
    end
  end


  protected
  def set_content_type
    headers['Content-Type'] = 'text/javascript'
  end

  def perform_dynamic_caching
    if dynamic_caching_enabled?
      self.class.cache_page dynamic_behaviours.to_s, request.path
    end
  end

  def perform_static_caching
    self.class.cache_page js_attach_behaviours, request.path
  end

  # making store_behaviours an empty method for this controller
  # so that generating static behaviours does not get rid of
  # dynamic behaviours in the session.
  def store_behaviours ; end

  private
  # Reads every mentioned file with static behaviours and joins them
  # to generate one nice .js file
  def collect_behaviours(static_behaviours)
    result = static_behaviours.inject('') do |memo, filename|
      if OhBehave::Configuration.careful_mode && !File.exist?(filename)
        logger.error "File defining behaviour #{filename} doesn't exist"
        memo
      else
        file_content = File.readlines(filename).join("").strip.chomp
        file_content << ',' unless file_content.empty? || file_content =~ /,\Z/
        memo + file_content + "\n"
      end
    end
    result.sub(/,\s*\Z/, '')
  end

  def generate_etag(content)
    headers['ETag'] = Digest::MD5.hexdigest(content)
  end

  def modified?
    request.env['HTTP_IF_NONE_MATCH'] != headers['ETag']
  end

  def render_dynamic_script
    logger.debug dynamic_behaviours.to_s
    render :text => dynamic_behaviours.to_s, :layout => false
  end

  def render_304
    render :nothing => true, :status => 304
  end

  def empty_static_behaviours
    session[:static_behaviours] = nil
  end

  def empty_dynamic_behaviours
    session[:dynamic_behaviours] = nil
  end

  def js_attach_behaviours
    <<EOF
Event.addBehavior({
#{@js_static_behaviours}
});
EOF
  end

  def dynamic_caching_enabled?
    dynamic_behaviours && dynamic_behaviours.cache?
  end

end
