require 'rack'
require_relative '../lib/router'
require_relative '../models/application_model'
require_relative '../models/cat'
require_relative '../models/human'
require_relative '../models/house'
require_relative '../controllers/application_controller'
require_relative '../controllers/cats_controller'
# require_relative '../controllers/humen_controller'
# require_relative '../controllers/houses_controller'

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  post Regexp.new("^/cats$"), CatsController, :create
  delete Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :destroy
  patch Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :update
  get Regexp.new("^/cats/(?<id>\\d+)/edit$"), CatsController, :edit
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)