require_relative 'route'

class Router
  attr_reader :routes, :patterns

  def initialize
    @routes = []
    @patterns = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    routes << Route.new(pattern, method, controller_class, action_name)
    patterns << pattern unless patterns.include?(pattern)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :patch, :delete, :put].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    routes.find { |route| route.matches?(req) }
  end

  def resources(name, options = {})
    controller_class = "#{name.capitalize}Controller".constantize
    methods = [:index, :create, :new, :edit, :update, :show, :destroy]
    patterns = {
      index: [Regexp.new("^/#{name}/?$"), :get],
      new: [Regexp.new("^/#{name}/new/?$"), :get],
      show: [Regexp.new("^/#{name}/(?<id>\\d+)/?$"), :get],
      create: [Regexp.new("^/#{name}$"), :post],
      destroy: [Regexp.new("^/#{name}/(?<id>\\d+)/?$"), :delete],
      update: [Regexp.new("^/#{name}/(?<id>\\d+)/?$"), :patch],
      edit: [Regexp.new("^/#{name}/(?<id>\\d+)/edit/?$"), :get]
    }
    
    default = { only: methods, except: [] }
    default.merge!(options)
    names = default[:only] - default[:except]

    names.each do |name|
      params = patterns[name] + [controller_class] + [name]
      add_route(*params)
    end
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route = match(req)
    if route
      route.run(req, res, patterns)
    else
      res.status = 404
      res.write('Route not found')
    end
  end
  
end
