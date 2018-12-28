require_relative '../lib/controller_base'

class CatsController < ControllerBase
  protect_from_forgery

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
    p cat_params
    cat = Cat.new(cat_params)
    cat.save
    redirect_to("/cats/#{cat.id}")
  end

  def edit
    @cat = Cat.find(params['id'])
  end

  def update
    cat = Cat.find(params['id'])
    cat.update_params(cat_params)
    cat.save
    redirect_to("/cats/#{cat.id}")
  end

  def destroy
    cat = Cat.find(params['id'])
    cat.destroy
    redirect_to("/cats")
  end

  def cat_params
    params.require(:cat).permit(:name, :owner_id)
  end
end