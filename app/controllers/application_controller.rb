class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :admin?, :get_categories

  def get_categories
    menu = {}
    MenuItem.all.each do |item|
      menu[item.category] ||= []
      menu[item.category] << item
    end
    menu
  end


  protected

  def authorize
    unless admin?
      flash[:error] = "unauthorized access"
      redirect_to home_path
      false
    end
  end

  def admin?
    session[:password] == "kittens"
  end
end
