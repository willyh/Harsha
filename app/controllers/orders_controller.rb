class OrdersController < ApplicationController
  helper_method :build_menu
  before_filter :completed_yet, :except => [:new, :create, :show, :complete ]
  def new
    @head = "Check Out Our Menu!"
    @order = Order.new
  end
  def index
    redirect_to new_order_path
  end

   def create
    @order = Order.new((params[:order] || {}).merge({:items => (params[:items] || []).join("\n")}))
    if admin?
      if @order.items.empty?
        flash[:notice] = "I don't think you want an empty order"
        redirect_to new_order_path
      else
        @order.save(false)
        @order.print
        render new_order_path
      end
    else
      if waited_too_long @order
        flash[:error] = "Please select a time later than #{@order.pickup_time}. We may need more than #{time_to_prepare @order.pickup_time} minutes to prepare your food"
        @head = "Check Out Our Menu!"
        render 'new'
      elsif @order.save()
        redirect_to @order
      else
        @head = 'Check Out Our Menu!"'
        render 'new'
      end
    end
  end

  def show
    redirect_to new_order_path if !params[:id]
    if !Order.exists?(params[:id])
      flash[:error] = "404:error order not found "
      redirect_to home_path
    else
      @order = Order.find params[:id]
      @head = !@order.customer_name.blank? ? "#{@order.customer_name}'s Order" : "Order"
    end
  end

  def destroy
    if params[:id]=="clear"
      Order.all.each do |o|
        o.destroy
      end
      redirect_to new_order_path
    else
      if Order.exists? params[:id]
        Order.find(params[:id]).destroy
        if admin?
          redirect_to new_order_path
         else
           flash[:notice] = "Your order has been cancelled"
           redirect_to home_path
         end
      else
        flash[:error] = "Your order has already been deleted"
	redirect_to home_path
      end
    end
  end

  def complete
    @order = Order.find(params[:id])
    @order.complete
    flash[:success] = "Thank You"
    redirect_to @order
  end

protected
  def time_to_prepare pickup_time
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

  def build_tables categories
    i = 3
    categories.each do |cat, item|
      three_category_sets[i/3] ||= []
      three_category_sets[i/3] << cat
      i = i+1
    end
    i = 1
    tables[:category_sets] = three_category_sets
    three_category_sets.each do |category_set|
      tables[i] = build_table category_set
      i += 1
    end
    tables
  end
  def completed_yet
    if params[:id].nil?
      redirect_to new_order_path
    elsif !Order.exists?(params[:id])
      flash[:error] = "404:error order not found "
      redirect_to home_path
    else
      unless  admin? || !Order.find(params[:id]).completed
        flash[:error] = "Cannot delete an order once it has been placed"
        redirect_to home_path
        false
      end
    end
  end


end
