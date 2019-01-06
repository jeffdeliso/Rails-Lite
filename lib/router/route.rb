class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name = pattern, http_method, controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    method = req.params['_method'] || req.request_method
    pattern =~ req.path && http_method.to_s == method.downcase
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res, patterns)
    route_params = {}
    match_data = pattern.match(req.path)
    match_data.names.each do |key|
      route_params[key] = match_data[key]
    end
    
    controller = controller_class.new(req, res, route_params, patterns)
    controller.invoke_action(action_name)
  end
end
