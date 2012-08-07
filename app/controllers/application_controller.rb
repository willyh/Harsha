class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :admin?, :active?

  def active?
    return Setting.first.last_activation_date < Time.now && Time.now < Setting.first.closes_at
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
