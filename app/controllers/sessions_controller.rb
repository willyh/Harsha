class SessionsController < ApplicationController
  def new
    @head = "Login"
  end

  def create
    session[:password] = params[:session][:password]
    if session[:password] == "kittens"
      flash[:success] = "Welcome Back Captain!"
    end
    redirect_to home_path
  end

  def destroy
    reset_session
    flash[:notice] = "Session has been reset"
    redirect_to home_path
  end
end
