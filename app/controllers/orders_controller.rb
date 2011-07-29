class OrdersController < ApplicationController
  helper_method :build_menu
  before_filter :completed_yet, :except => [:new, :create, :show, :complete ]
  def new
    @head = "Place Your Order"
    @order = Order.new
  end

   def create
    @order = Order.new((params[:order] || {}).merge({:items => (params[:items] || []).join("\n")}))
    if admin?
      if @order.items.empty?
        flash[:notice] = "I don't think you want to print out a blank receipt"
        redirect_to new_order_path
      else
        puts @order.save(false)
        @order.print
        redirect_to new_order_path
      end
    else
      if waited_too_long @order
        flash[:error] = "Please select a time later than #{@order.pickup_time}. We may need more than #{time_to_prepare_food @order.pickup_time} minutes to prepare your food"
        redirect_to new_order_path
      elsif @order.save()
        redirect_to @order
      else
        @head = 'Place Your Order'
        render 'new'
      end
    end
  end

  def index
    @head = "All Orders"
    @orders = Order.find(:all, :conditions => 'completed IS NOT NULL')
  end
  def destroy
    pickup_time = Order.find(params[:id]).pickup_time
    Order.find(params[:id]).destroy
    if admin?
      redirect_to new_order_path
    else
      flash[:notice] = "Your order has been cancelled"
      redirect_to home_path
    end
  end

  def show
    @order = Order.find(params[:id])
    if @order.customer_name.blank?
      @head = "Order"
    else
      @head = "#{@order.customer_name}'s Order"
    end
  end

  def complete
    @order = Order.find(params[:id]).complete
    flash[:success] = "thank you"
    redirect_to home_path
  end

protected
  def time_to_prepare_food pickup_time
    return (time_from_string(pickup_time) - (Time.now.utc.hour.hours-4.hours) - Time.now.utc.min.minutes)/60
  end
  def waited_too_long order
    time_from_string(@order.pickup_time) <= (Time.now.utc.hour.hours - 4.hours) + Time.now.utc.min.minutes + 3.minutes
  end

  def time_from_string time_string
    arr = time_string.split(":")
    pm = 12.hours if arr.last.include?("PM")
    hours = arr.first.to_i.hours + (pm || 0)
    minutes = arr.last.slice(0,2).to_i.minutes
    hours + minutes
  end

  def build_menu
    menu ={} 
    menu[1] = {}
    MenuItem.all.each do |item|
      check 1, menu, item unless item.out_of_stock
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

  def completed_yet
    
    unless  admin? || !Order.find(params[:id]).completed
      flash[:error] = "Cannot delete an order once it has been placed"
      redirect_to home_path
      false
    end
  end

end
