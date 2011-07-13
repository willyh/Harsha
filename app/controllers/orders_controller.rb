class OrdersController < ApplicationController
  def new
    @order = Order.new
    @menu_items = MenuItem.all
    @head = "Make an Order"
  end

end
