require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params


  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = req.params.merge(route_params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    p url
    unless @already_built_response
      @already_built_response = true
      res.status = 302
      res['Location'] = url
      session.store_session(res)
      flash.store_flash(res)
    else
      raise "Can't render/redirect more than once"
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    unless already_built_response?
      @already_built_response = true
      res['Content-Type'] = content_type
      res.write(content)
      session.store_session(res)
      flash.store_flash(res)
    else
      raise "Can't render/redirect more than once"
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    directory = File.expand_path(Dir.pwd)
    controller_name = self.class.to_s.underscore
    path = File.join(directory, 'views', controller_name, "#{template_name}.html.erb")
    content = ERB.new(File.read(path)).result(binding)
    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  def flash
    @flash ||= Flash.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end

    self.send(name)
    render name unless already_built_response?
  end

  def form_authenticity_token
    @form_authenticity_token ||= SecureRandom::urlsafe_base64
    cookie = { path: '/', value: @form_authenticity_token }
    res.set_cookie('authenticity_token', cookie)
    @form_authenticity_token
  end

  def check_authenticity_token
    unless params['authenticity_token'] && req.cookies['authenticity_token'] == params['authenticity_token'] 
      raise 'Invalid authenticity token'
    end
  end

  def protect_from_forgery?
    @@protect_from_forgery ||= false
  end

end

