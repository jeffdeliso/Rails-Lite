require 'rack'
require_relative '../lib/controller_base.rb'
require_relative '../lib/router'
require_relative '../lib/sql_object'
require_relative '../lib/controller_base'

class Cat < SQLObject
  Cat.finalize!
end

class CatsController < ControllerBase
  def index
    @cats = Cat.all
  end

  def new
    @cat = Cat.new
  end

  def show
    @cat = Cat.find(params['id'])
  end

  def create
    cat = Cat.new(params['cat'])
    cat.save
    redirect_to("/cats/#{cat.id}")
  end

  def edit
    @cat = Cat.find(params['id'])
  end

  def update
    cat = Cat.find(params['id'])
    cat.update_params(params['cat'])
    cat.save
    redirect_to("/cats/#{cat.id}")
  end

  def destroy
    cat = Cat.find(params['id'])
    cat.destroy
    redirect_to("/cats")
  end
end

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