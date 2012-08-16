class OrdersController < ApplicationController
  helper_method :build_menu
  before_filter :completed_yet, :except => [:new, :create, :show, :complete, :add_feature ]
  before_filter :website_active?, :only => [:new, :create, :add_feature]
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

	def add_feature
    if session[:order] && Order.exists?(session[:order])
      @order = Order.find(session[:order]) 
			@order = Order.create() if @order.completed && !@order.pickup_time.nil?
    else
      @order = Order.create()
    end
		@settings = Setting.first
		if MenuItem.exists?(@settings.feature)
			@feature = MenuItem.find(@settings.feature)
			if @order.selections.empty?
				@order.selections << Selection.new(:menu_item => @feature)
				@order.update_price!
				@order.save
			end
		end
    session[:order] = @order.id
		redirect_to new_order_path

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
    @order = Order.find(params[:id])
    if @order.completed && params[:order] && params[:order][:pickup_time] && (has_pickup_time? (Time.parse params[:order][:pickup_time]))
      @order.update_attributes(:pickup_time => params[:order][:pickup_time])
      flash[:success] = "Thank you, Please come down at #{format_time @order.pickup_time.to_time.localtime} to pick up your order"
			@order.print
      redirect_to order_path(params[:id])
    else
      flash[:error] = "That pickup time is either full or invalid. Please choose another"
      redirect_to @order
    end
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
			@settings = Setting.first
      flash[:notice] = (Time.now > @settings.closes_at) ?
			"Sorry, we're closed. Store hours are from #{format_time @settings.opens_at} to #{format_time @settings.closes_at}" :
			"Sorry, we're not currently accepting online orders"
      redirect_to menu_path
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
      if  !admin? && @order.completed && params[:order] && !params[:order][:pickup_time]
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
  
  def format_time time
    return "" unless time
    time_s = time.localtime.strftime("%I:%M%p")
    return time_s.slice(1,6) if time_s.first == "0"
    time_s
  end

  def has_pickup_time? time
    @settings = Setting.first
		closes_at = @settings.closes_at.localtime
		opens_at = @settings.opens_at.localtime
    valid = Order.all.select{|o|o.pickup_time == time}.count < @settings.max_per_slot || @settings.max_per_slot < 0
		valid = valid && time < closes_at
		valid = valid && opens_at < time
		valid = valid && time > Time.now + @settings.interval.minutes
  end
end
