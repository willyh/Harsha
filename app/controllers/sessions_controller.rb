class SessionsController < ApplicationController
  def new
    @head = "Login"
  end

  def create
    session[:password] = params[:session][:password]
    if session[:password] == APP_CONFIG['admin_pass']
      flash[:success] = "Welcome Back Captain!"
      redirect_to edit_setting_path(1)
    else
      redirect_to home_path
    end
  end

  def destroy
    reset_session
    flash[:notice] = "Session has been reset"
    redirect_to home_path
  end
end
