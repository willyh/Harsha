class PaymentNotificationController < ApplicationController
  protect_from_forgery :except => [:create]

  def create
    MenuItem.create!(:name => "Paypal made this", :price => 0, :category => "payment_notification", :description => (params[:invoice] || "no params"))
    PaymentNotification.create!(:params => params, :order_id => params[:invoice], :status => params[:payment_status], :transaction_id => params[:txn_id])
  end

end
