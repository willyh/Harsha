class OrdersController < ApplicationController
  helper_method :build_menu
  before_filter :completed_yet, :except => [:new, :create, :show, :complete ]
  def new
    if session[:order] && Order.exists?(session[:order])
      @order = Order.find(session[:order]) 
    else
      @order = Order.create()
    end
    session[:order] = @order.id
    @categories = Category.all.select{|c|
      c.menu_items.select{|m|
        m.out_of_stock == false
      }.empty? == false
    }
    @head = "Check Out Our Menu!"
  end
  def index
    redirect_to new_order_path
  end

  def create
    if Order.exists?(params[:id]) && Order.find(params[:id]).completed
      redirect_to new_order_path
    end
  end

  def update_name
      se = session[:order]
    if Order.exists?(params[:id])
      @order = Order.find(params[:id])
      id = @order.id
      @order.update_attributes(params[:order])
      names = @order.customer_name.split(" ")
      render(:update) {|page|
        page << "jQuery('#first_name').val('#{names[0]}')" if names.count > 0
        page << "jQuery('#last_name').val('#{names[-1]}')" if names.count > 1
      }
    else
      render :nothing => true
    end
  end

  def show
    @order = Order.find params[:id]
    @head = params[:id] == session[:order].to_s ? "#{@order.customer_name}'s Order" : "Order #{params[:id]}"
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
  def authorize_order
    if Order.find(params[:id]).completed
      unless session[:order] == params[:id] || admin?
        flash[:error] = "Order already complete"
        redirect_to new_order_path
      end
    end
  end

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

  def completed_yet
    if params[:id].nil?
      redirect_to new_order_path
    elsif !Order.exists?(params[:id])
      flash[:error] = "404:error order not found "
      redirect_to home_path
    else
      unless  admin? || !Order.find(params[:id]).completed
        flash[:error] = "Cannot change an order once it has been placed"
        redirect_to home_path
        false
      end
    end
  end
  

end
