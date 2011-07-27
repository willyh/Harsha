class OrdersController < ApplicationController
  helper_method :build_menu
  before_filter :authorize, :except => [:new, :edit, :create, :update, :show, :destroy ]
  def new
    @head = "Place Your Order"
    @order = Order.new
  end

  def edit
    @menu_items = MenuItem.all
    @order = Order.find(params[:id])
    @head = "Add to Order"
  end

  def create
    categories = get_categories
    items = ""
    categories.each do |key, value|
      items += "#{params[key]}\n" if params[key]
    end
    @order = Order.new(params[:order].merge({:items => items}))

    if @order.save
      flash[:success] = "Your order has been placed!"
      redirect_to @order
    else
      @head = 'Place Your Order'
      render 'new'
    end
  end

  def update
    @order = Order.find(params[:id])
    if params[:order] 
      if params[:order].has_key? :item_addition
        redirect_to edit_order_path @order if @order.update_attributes(@order.add_items params[:order])
      elsif params[:order].has_key? :pickup_time
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
      redirect_to orders_path
  end

  def show
    @order = Order.find(params[:id])
    if @order.customer_name.blank?
      @head = "Order"
    else
      @head = "#{@order.customer_name}'s Order"
    end
  end
  def build_menu
    menu ={} 
    menu[1] = {}
    MenuItem.all.each do |item|
      check 1, menu, item
    end
    menu
  end
  def check index, menu, item
    menu[index] ||= {}
    if menu[index][item.category]
      check index + 1, menu, item
    else
      menu[index][item.category] = item
    end
  end

end
