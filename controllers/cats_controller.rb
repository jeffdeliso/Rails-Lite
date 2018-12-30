class CatsController < ApplicationController
  protect_from_forgery

  def index
    @cats = Cat.all
  end
  
  def new
    ensure_login
    @cat = Cat.new
  end
  
  def show
    @cat = Cat.find(params['id'])
  end
  
  def create
    @cat = Cat.new(cat_params)
    if @cat.save
      redirect_to cat_url(@cat)
    else
      flash.now['errors'] = @cat.errors
      render :new
    end
  end
  
  def edit
    @cat = Cat.find(params['id'])
  end
  
  def update
    @cat = Cat.find(params['id'])
    @cat.update_params(cat_params)
    if @cat.save
      redirect_to cat_url(@cat)
    else
      flash.now['errors'] = @cat.errors
      render :edit
    end
  end
  
  def destroy
    cat = Cat.find(params['id'])
    cat.destroy
    redirect_to cats_url
  end
  
  private
  
  def cat_params
    params.require(:cat).permit(:name, :owner_id)
  end

  before_action :ensure_login, only: [:new, :create, :edit, :update, :destroy]
end