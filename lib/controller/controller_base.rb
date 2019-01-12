require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require 'json'
require_relative './cookies/session'
require_relative './cookies/flash'
require_relative './strong_params'
require_relative './controller_callbacks'

class ControllerBase
  extend ControllerCallbacks

  attr_reader :req, :res, :params

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def self.make_helpers(patterns)
    patterns.each do |pattern|
      url_arr = pattern.inspect.delete('\^$?<>/+()')
        .split('\\').drop(1).reject { |el| el == "d"}

      if url_arr.any? { |str| str.include?("_id") }
        
      elsif url_arr.include?("id")
        make_id_helpers(url_arr)
      else
        make_idless_helpers(url_arr)
      end
    end
  end

  def initialize(req, res, route_params = {}, patterns)
    @req = req
    @res = res
    @params = StrongParams.new_syms(req.params.merge(route_params))
    @already_built_response = false
    self.class.make_helpers(patterns)
  end

  def invoke_action(name)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end
    
    self.send(name)
    render name unless already_built_response?
    
    nil
  end
  
  def form_authenticity_token
    @form_authenticity_token ||= SecureRandom::urlsafe_base64
    cookie = { path: '/', value: @form_authenticity_token }
    res.set_cookie("#{@form_authenticity_token[0..5]}authenticity_token", cookie)
    @form_authenticity_token
  end
  
  def link_to(name, path)
    "<a href=\"#{path}\">#{name}</a>"
  end
  
  def root_url
    '/'
  end

  protected
  
  def redirect_to(url)
    prepare_render_or_redirect
    
    res.status = 302
    res['Location'] = url
    
    nil
  end

  def render(options)
    if options.is_a?(Symbol)
      render_template(options)
    else
      render_json(options[:json])
    end
  end

  def session
    @session ||= Session.new(req)
  end
  
  def flash
    @flash ||= Flash.new(req)
  end
  
  private

  def render_json(obj)
    content = obj.attributes.to_json
    render_content(content, 'application/json')
  end

  def render_template(template_name)
    directory = File.dirname(__FILE__)
    controller_name = self.class.to_s.underscore
    path = File.join(
      directory, "..", '..',
      'app', 'views', controller_name,
      "#{template_name}.html.erb"
    )
      
    content = ERB.new(File.read(path)).result(binding)
    app_content = build_content { content }
    render_content(app_content, 'text/html')
  end

  def self.make_idless_helpers(url_arr)
    helper_name = url_arr.reverse.join("_")
    helper_name += "_url"
    url = url_arr.join("/")
    url = "/" + url
    define_method(helper_name) do
      url
    end
  end

  def self.make_id_helpers(url_arr)
    name_arr = url_arr.dup
    name_arr[0] = url_arr.first.singularize
    helper_name = name_arr.reject { |el| el == "id"}.reverse.join("_")
    helper_name += "_url"

    define_method(helper_name) do |id|
      obj_id = id.try(:id)
      url = url_arr.map do |el|
        if el == "id"
          "#{obj_id || id}"
        else
          el
        end
      end
        
      "/" + url.join("/")
    end
  end

  def already_built_response?
    @already_built_response
  end
  
  def render_content(content, content_type)
    prepare_render_or_redirect

    res['Content-Type'] = content_type
    # app_content = build_content { content }
    res.write(content)
    nil
  end

  def prepare_render_or_redirect
    raise "double render error" if already_built_response?
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  def build_content(&prc)
    directory = File.dirname(__FILE__)
    path = File.join(
      directory, '..', '..',
      'app', 'views', "application.html.erb"
    )

    app_content = ERB.new(File.read(path)).result(binding)
  end
  
  def check_authenticity_token
    param_token = params['authenticity_token']
    cookie = req.cookies["#{param_token[0..5]}authenticity_token"]
    unless param_token && cookie == param_token
      raise 'Invalid authenticity token'
    end
  end

  def protect_from_forgery?
    @@protect_from_forgery ||= false
  end
end

