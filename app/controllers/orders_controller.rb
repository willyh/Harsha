class OrdersController < ApplicationController
  helper_method :build_menu
  before_filter :authorize, :except => [:new, :create ]
  def new
    @head = "Place Your Order"
    @order = Order.new
  end

   def create
    categories = get_categories
puts "f;lqewhr;oeqw #{params[:items]}"
    @order = Order.new(params[:order].merge({:items => params[:items].join("\n")}))

    if @order.save
      flash[:success] = "Your order has been placed!"
      redirect_to @order
    else
      @head = 'Place Your Order'
      render 'new'
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
