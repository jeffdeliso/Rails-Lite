require 'thor'
require 'rack'
require 'pry'
require_relative './lib/router'
require_relative './lib/routes'
require_relative './models/application_model'
require_relative './models/cat'
require_relative './models/user'
require_relative './models/house'
require_relative './controllers/application_controller'
require_relative './controllers/cats_controller'
require_relative './controllers/users_controller'
require_relative './controllers/sessions_controller'

  class RL < Thor
    
    desc "server", "start rails lite server"
    method_option :aliases => "s"
    def server
      router = Router.new
      create_routes(router)

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
    end

    desc "console", "start rails lite console"
    method_option :aliases => "c"
    def console
      Pry.start(__FILE__)
    end
  end

