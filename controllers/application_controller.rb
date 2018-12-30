require_relative '../lib/controller_base'

class ApplicationController < ControllerBase

  def current_user
    @current_user ||= User.find_by(session_token: session[:session_token])
  end

  def ensure_login
    unless logged_in?
      flash[:errors] = ['must be logged in']
      redirect_to new_sessions_url
    end
  end

  def login(user)
    @current_user = user
    session[:session_token] = user.reset_token!
    session[:session_token]
  end

  def logout
    current_user.reset_token!
    session[:session_token] = nil
    @current_user = nil
  end

  def logged_in?
    !!current_user
  end
end