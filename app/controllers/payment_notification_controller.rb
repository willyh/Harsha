class PaymentNotificationController < ApplicationController
  protect_from_forgery :except => [:create]

  def create
    MenuItem.create!(:name => "Paypal made this", :price => 0, :category => "payment_notification", :description => "Order id is #{params[:invoice]} status is #{params[:payment_status]} transaction id is #{:txn_id}")
    PaymentNotification.create!( :order_id => params[:invoice], :status => params[:payment_status], :transaction_id => params[:txn_id])
  end

end
