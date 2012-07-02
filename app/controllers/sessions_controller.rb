class SessionsController < ApplicationController
  def new
    @head = "Login"
  end

  def create
    session[:password] = params[:session][:password]
    if session[:password] == "kittens"
      flash[:success] = "Welcome Back Captain!"
    else
      flash[:error] = "Wrong password. Reset to try again"
    end
    redirect_to home_path
  end

  def destroy
    reset_session
    flash[:notice] = "Successfully reset session"
    redirect_to home_path
  end
end
