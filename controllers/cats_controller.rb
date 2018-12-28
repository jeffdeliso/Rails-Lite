require_relative '../lib/controller_base'

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