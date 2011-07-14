class OrdersController < ApplicationController
  def new
    @order = Order.new
    @head = "Make an Order"
  end

  def edit
    @menu_items = MenuItem.all
    @order = Order.find(params[:id])
    @head = "Add to Order"
  end

  def create
    @order = Order.new(params[:order])
    if @order.save
      redirect_to edit_order_path @order
    else
      render 'new'
    end
  end

  def update
    @order = Order.find(params[:id])
    if params[:order].has_key? :customer_name
      if @order.update_attributes(params[:order])
        redirect_to orders_path
      end
    elsif @order.update_attributes(@order.add_items params[:order])
      redirect_to edit_order_path @order
    else
      render 'edit'
    end
  end

  def index
    @head = "All Orders"
    @orders = Order.all
  end
end
