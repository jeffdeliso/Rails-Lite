require_relative 'route'

class Router
  attr_reader :routes, :patterns

  def initialize
    @routes = []
    @patterns = []
    @current_route = "^/"
    @member_route = "^/"
    @collection_route = "^/"
    @nested_route = "^/"
    @current_class = nil;
  end

  def see_routes
    patterns.each do |pattern|
      p url = pattern.inspect.delete('\^$?<>/+()')
        .split('\\').drop(1).reject { |el| el == "d"}.join('/')
    end
  end

  def add_route(pattern, method, controller_class, action_name)
    routes << Route.new(pattern, method, controller_class, action_name)
    patterns << pattern unless patterns.include?(pattern)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :patch, :delete, :put].each do |http_method|
    define_method(http_method) do |name, options = {}|
      default = { to: "#{current_class}##{name}" }
      default.merge!(options)

      to_array = default[:to].split('#')
      pattern = Regexp.new("#{current_route}#{name}/?$")
      controller_class = "#{to_array[0].capitalize}Controller".constantize
      action_name = to_array[1].to_sym

      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    routes.find { |route| route.matches?(req) }
  end

  def resources(name, options = {}, &prc)
    controller_class = "#{name.capitalize}Controller".constantize
    methods = [:index, :create, :new, :edit, :update, :show, :destroy]
    patterns = {
      index: [Regexp.new("#{current_route}#{name}/?$"), :get],
      new: [Regexp.new("#{current_route}#{name}/new/?$"), :get],
      show: [Regexp.new("#{current_route}#{name}/(?<id>\\d+)/?$"), :get],
      create: [Regexp.new("#{current_route}#{name}$"), :post],
      destroy: [Regexp.new("#{current_route}#{name}/(?<id>\\d+)/?$"), :delete],
      update: [Regexp.new("#{current_route}#{name}/(?<id>\\d+)/?$"), :patch],
      edit: [Regexp.new("#{current_route}#{name}/(?<id>\\d+)/edit/?$"), :get]
    }
    
    default = { only: methods, except: [] }
    default.merge!(options)
    names = default[:only] - default[:except]

    names.each do |name|
      params = patterns[name] + [controller_class] + [name]
      add_route(*params)
    end

    self.current_class = name
    set_resources_routes(name)
    prc.call if prc
    reset_routes

    see_routes
    nil
  end

  def resource(name, options = {}, &prc)
    controller_class = "#{name.capitalize}Controller".constantize
    methods = [:index, :create, :new, :edit, :update, :show, :destroy]
    patterns = {
      index: [Regexp.new("#{current_route}#{name}/?$"), :get],
      new: [Regexp.new("#{current_route}#{name}/new/?$"), :get],
      show: [Regexp.new("#{current_route}#{name}/?$"), :get],
      create: [Regexp.new("#{current_route}#{name}$"), :post],
      destroy: [Regexp.new("#{current_route}#{name}/?$"), :delete],
      update: [Regexp.new("#{current_route}#{name}/?$"), :patch],
      edit: [Regexp.new("#{current_route}#{name}/edit/?$"), :get]
    }
    
    default = { only: methods, except: [] }
    default.merge!(options)
    names = default[:only] - default[:except]

    names.each do |name|
      params = patterns[name] + [controller_class] + [name]
      add_route(*params)
    end

    self.current_class = name
    set_resource_routes(name)
    prc.call if prc
    reset_routes

    nil
  end

  def member(&prc)
    self.current_route = member_route
    prc.call if prc
    self.current_route = nested_route

    nil
  end

  def collection(&prc)
    self.current_route = collection_route
    prc.call if prc
    self.current_route = nested_route

    nil
  end

  def root(options = {})
    to_array = options[:to].split('#')
    pattern = Regexp.new("^/?$")
    http_method = :get
    controller_class = "#{to_array[0].capitalize}Controller".constantize
    action_name = to_array[1].to_sym

    add_route(pattern, http_method, controller_class, action_name)
  end

  def run(req, res)
    route = match(req)
    if route
      route.run(req, res, patterns)
    else
      res.status = 404
      res.write('Route not found')
    end
  end

  private 
  attr_accessor :current_route, :member_route, :collection_route,
    :nested_route, :current_class

  def set_resources_routes(name)
    self.member_route = current_route +  "#{name}/(?<id>\\d+)/"
    self.collection_route = current_route +  "#{name}/"
    self.nested_route = current_route + "#{name}/(?<#{name.to_s.singularize}_id>\\d+)/"
    self.current_route = nested_route
  end

  def set_resource_routes(name)
    self.member_route = current_route +  "#{name}/"
    self.collection_route = current_route +  "#{name}/"
    self.nested_route = current_route +  "#{name}/"
    self.current_route = nested_route
  end

  def reset_routes
    self.current_route = "^/"
    self.member_route = "^/"
    self.collection_route = "^/"
    self.nested_route = "^/"
    self.current_class = nil
  end
end
