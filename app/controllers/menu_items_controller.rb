class MenuItemsController < ApplicationController
  before_filter :authorize, :except =>  [:home, :index]
  def index
		redirect_to new_order_path if active?
    @head = "Check Out Our Menu!"
    @categories = Category.all.select{|c|
      c.menu_items.select{|m|
        m.out_of_stock == false
      }.empty? == false
    }
  end

  def create
    #@menu_item and @new_item will be the same unless returning from
    #a failed update then new_item will be new and
    #menu_item will be the item that failed to update

    @categories = Category.all
    @options = Option.all
    @new_option = Option.new
    @new_item = MenuItem.new(params[:menu_item])
    @menu_item = @new_item

    category = params[:menu_item][:category]
    if category.empty?
      @new_item.save
      @head = "Error"
      return render 'new' 
    end
    if !Category.exists?(:name => category)
      @category =  Category.new(:name => category, :display_order => Category.count+1)
      if !@category.save
        @head = "Error"
        return render 'new'
      end
    end
    @category = Category.find_by_name(category)
    @new_item.out_of_stock = true
    @new_item.display_order = @category.menu_items.count+1
    @new_item.category = @category
    if @new_item.save
      @category.menu_items << @new_item
      flash[:success] = "#{@new_item.name} successfully added to menu!"
			redirect_to new_menu_item_path(:id => @menu_item.id)
    else
      @head = "Error"
      render 'new'
    end
  end

  def update
    @new_item = MenuItem.new

    @menu_item = MenuItem.find(params[:id])
    if @menu_item.update_attributes(params[:menu_item])
      old_cat = @menu_item.category
      new_cat = params[:menu_item][:category]
      if old_cat.name != new_cat
        @category = Category.find_by_name(new_cat)
        if @category.nil?
          @category = Category.create(:name => new_cat, :display_order => Category.count+1)
        end
        @category.menu_items << @menu_item
        order = @menu_item.display_order
        @menu_item.update_attributes(:display_order => @category.menu_items.count)
        if old_cat.menu_items.count == 0
          order = old_cat.display_order
          old_cat.destroy
          Category.select{|c|c.display_order > order}.each {|c|
            c.update_attributes(:display_order => c.display_order - 1)
          }
        else
          old_cat.menu_items.select{|i|i.display_order > order}.each {|i|
            i.update_attributes(:display_order => i.display_order - 1)
          }
        end
      end
      flash[:success] = "Successful change"
			redirect_to new_menu_item_path(:id => @menu_item.id)
    else
      @head = "Error"
			redirect_to new_menu_item_path(:id => @menu_item.id)
    end
  end

  def show
    @menu_item = MenuItem.find(params[:id])
		redirect_to new_menu_item_path(:id => @menu_item.id)
  end

  def new
    @new_item = MenuItem.new
    @menu_item = @new_item
    @new_option = Option.new
    @category = Category.new
    @head = "Check Out Your Menu"
    @categories = Category.all
    @options = Option.all
  end

  def destroy
    item = MenuItem.find(params[:id])
    category = Category.find(item.category_id)
    item.destroy
    category.destroy if category.menu_items.count == 0
    
    flash[:success] = "#{item.name} deleted"
		redirect_to new_menu_item_path
  end

  def home
    @head = "Moto Cafe"
    @settings = Setting.first
		@feature = MenuItem.find(@settings.feature) if MenuItem.exists?(@settings.feature)
  end

  def toggle_stock 
    @menu_item = MenuItem.find(params[:id])
    @menu_item.toggle_stock
    @menu_item.save
    render(:update) {|page|
      page << "jQuery('#in_stock_#{params[:id]}').attr('class','#{@menu_item.out_of_stock ? "disabled" : "in_stock"}')"
      page << "jQuery('#out_of_stock_#{params[:id]}').attr('class','#{@menu_item.out_of_stock ? "out_of_stock" : "disabled"}')"
      if !@menu_item.out_of_stock
        page << "jQuery('##{params[:id]}').removeClass('dim')"
      else
        page << "jQuery('##{params[:id]}').addClass('dim')"
      end
    }
  end

  def change_order
    unless(params[:display_order].nil?)
      @menu_item = MenuItem.find(params[:id])
      @swap_item = Category.find(@menu_item.category_id).menu_items.find_by_display_order(params[:display_order])
      unless(@menu_item.display_order.nil? || @swap_item.nil?)
        temp = @menu_item.display_order
        @swap_item.display_order = temp
        @swap_item.save
      end
      @menu_item.display_order = params[:display_order]
      @menu_item.save

      render(:update) {|page|
        page << "jQuery('##{@swap_item.id}').find('input').val('#{@swap_item.display_order}')"
        page << "jQuery('##{@menu_item.id}').swap('##{@swap_item.id}')"
      }
    end
  end

  def add_option
    if Option.exists?(params[:option]) && MenuItem.exists?(params[:id])
      @option = Option.find(params[:option])
      @menu_item = MenuItem.find(params[:id])
      @menu_item.options << @option
    end
    render(:update) {|page|
      page.replace_html "#{@menu_item.id}_options", {:partial => "editable_options", :locals => {:item => @menu_item}}
      page << "fixFocusForMobile()"
    }
  end

  def remove_option
    if Option.exists?(params[:option]) && MenuItem.exists?(params[:id])
      @option = Option.find(params[:option])
      @menu_item = MenuItem.find(params[:id])
      @menu_item.options.delete @option
    end
    render(:update) {|page|
      page.replace_html "#{@menu_item.id}_options", {:partial => "editable_options", :locals => {:item => @menu_item}}
      page << "fixFocusForMobile()"
    }
  end
end
