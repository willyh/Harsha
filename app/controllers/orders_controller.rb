class OrdersController < ApplicationController
  helper_method :build_menu
  before_filter :completed_yet, :except => [:new, :create, :show, :complete ]
  before_filter :website_active?, :only => [:new, :create]
  def new
    if session[:order] && Order.exists?(session[:order])
      @order = Order.find(session[:order]) 
        @order = Order.create() if @order.completed && !@order.pickup_time.nil?
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

  def update
    @option = Option.find(params[:id])
    if @option.update_attributes(params[:order])
      flash[:success] = "Your pickup time is #{format_time @option.pickup_time}. See you soon!"
    else
      flash[:error] = "That pickup time is either full or invalid. Please choose another"
    end
    redirect_to @order
  end

  def update_name
    if Order.exists?(params[:id])
      @order = Order.find(params[:id])
      id = @order.id
      @order.update_attributes(params[:order])
      render(:update) {|page|
        page.replace_html 'order_info', {:partial => "orders/editable_order", :locals => {:@order => @order}}
        page << "onResize()"
        page << "fixFocusForMobile()"
      }
    else
      render :nothing => true
    end
  end

  def show
    @order = Order.find params[:id]
    @head = "#{@order.customer_name}'s Order"
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

  def add_item_to
    @item = MenuItem.find(params[:item])
    o = Order.find(params[:id])
    o.selections << Selection.new(:menu_item => @item)
    if check_stock o
      o.update_price!
      o.save
      render(:update) {|page|
        page.redirect_to new_order_path
      }
    else
      o.update_price!
      o.save
      render(:update) {|page|
        page << "jQuery('.item-info').addClass('hidden')"
        page << "jQuery('#order_info').removeClass('hidden')"
        page.replace_html 'order_info', {:partial => "orders/editable_order", :locals => {:@order => o}}
        page << "onResize()"
        page << "fixFocusForMobile()"
      }
    end
  end

  def remove_item_from
    o = Order.find(params[:id])
    s = o.selections
    @selection = s[params[:selection].to_i]
    s.delete(@selection)

    if check_stock o
      o.update_price!
      o.save
      render(:update) {|page|
        page.redirect_to new_order_path
      }
    else
      check_stock o
      o.update_price!
      o.save

      render(:update) {|page|
        page.replace_html 'order_info', {:partial => "orders/editable_order", :locals => {:@order => o}}
        page << "onResize()"
        page << "fixFocusForMobile()"
      }
    end
  end
  
  def alter_option
    @order = Order.find(params[:id])
    @selection = @order.selections[params[:selection].to_i]
    @option = @selection.menu_item.options.find(params[:option])
    checkd = params[:checked] == "true"
    checkd = ! checkd if @option.price <= 0
    if checkd
      @selection.options << @option
    else
      @selection.options.delete(@option)
    end
    if check_stock @order
      @order.update_price!
      @order.save
      render(:update) {|page|
        page.redirect_to new_order_path
      }
    else
      @order.update_price!
      @order.save
      render(:update) {|page|
        page.replace_html 'order_info', {:partial => "orders/editable_order", :locals => {:@order => @order}}
        page << "onResize()"
        page << "fixFocusForMobile()"
      }
    end
  end

protected
  def website_active?
    unless active?
      flash[:notice] = "Sorry, our website is not currently active"
      redirect_to (admin? ? edit_setting_path(1) : home_path)
    end
  end
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
      flash[:error] = "404:Not Found"
      redirect_to home_path
    else
      @order = Order.find(params[:id])
      if params[:order] && params[:order][:pickup_time] && @order.completed
        Order.find(params[:id]).update_attributes(:pickup_time => params[:order][:pickup_time])
        flash[:success] = "Thank you, Please come down at blah to pick up your order"
        redirect_to order_path(params[:id])
      elsif  !admin? && Order.find(params[:id]).completed
        flash[:error] = "Cannot change an order once it has been placed"
        redirect_to home_path
        false
      end
    end
  end

  def check_stock order
    missing = []
    order.selections.each {|s|
      if s.menu_item.out_of_stock
        missing << s.menu_item.name
      else
        s.menu_item.options.each{|o|
          if o.out_of_stock
            missing << o.name
          end
        }
        s.options = s.options.reject {|o| o.out_of_stock}
      end
    }
    order.selections = order.selections.reject {|s| s.menu_item.out_of_stock}
    missing = missing.uniq
    flash[:error] = "Sorry! We just ran out of the following: #{missing.uniq.join(", ")}" if missing.count > 0
    return missing.count > 0
  end
  
  def active?
    return Setting.first.last_activation_date < Time.now && Time.now < Setting.first.closes_at
  end
end
