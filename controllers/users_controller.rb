class UsersController < ApplicationController
  protect_from_forgery

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.ensure_token
    if @user.save
      login(@user)
      redirect_to  cats_url
    else
      flash.now[:errors] = @user.errors
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end
end