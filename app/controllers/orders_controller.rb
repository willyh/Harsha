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
    if params[:order] 
      if params[:order].has_key? :item_addition
        redirect_to edit_order_path @order if @order.update_attributes(@order.add_items params[:order])
      elsif params[:order].has_key? :pickup_time
        redirect_to orders_path if @order.update_attributes(params[:order])
      end
    else
      @menu_items = MenuItem.all
      @order = Order.find(params[:id])
      @head = "Add to Order"
      render 'edit'
    end
  end

  def index
    @head = "All Orders"
    @orders = Order.all
  end
  def destroy
    pickup_time = Order.find(params[:id]).pickup_time
    Order.find(params[:id]).destroy
    if pickup_time.nil?
      redirect_to home_path
    else
      redirect_to orders_path
    end
  end
end
