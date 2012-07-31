class PaymentNotificationController < ApplicationController
  protect_from_forgery :except => [:create]

  def create
    if Order.exists?(params[:id])
      @order = Order.find(params[:id])
      if @order.secret == params[:key] && !@order.completed
        PaymentNotification.create!(:status => "Completed", :order_id => params[:id])
        redirect_to order_path(params[:id])
      else
        redirect_to order_path(params[:id])
      end
    else
      redirect_to new_order_path
    end
  end

end
