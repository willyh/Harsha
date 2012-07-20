class MenuItemsController < ApplicationController
  before_filter :authorize, :except =>  [:show, :home]
  def index
    @new_item = MenuItem.new
    @menu_item = @new_item
    @category = Category.new
    @head = "Check Out Your Menu"
    @categories = Category.all
  end

  def create
    #@menu_item and @new_item will be the same unless returning from
    #a failed update then new_item will be new and
    #menu_item will be the item that failed to update
    

    category = params[:menu_item][:category]
    if !Category.exists?(:name => category)
      @category =  Category.new(:name => category, :display_order => Category.count+1)
      if !@category.save
        @menu_item = MenuItem.new(params[:menu_item])
        @head = "Error"
        return render 'index'
      end
    end
    @category = Category.find_by_name(category)
    @new_item = MenuItem.new(params[:menu_item])
    @new_item.out_of_stock = true
    @new_item.display_order = @category.menu_items.count+1
    if @new_item.save
      @category.menu_items << @new_item
      flash[:success] = "#{@new_item.name} successfully added to menu!"
      redirect_to menu_path
    else
      @menu_item = @new_item
      @head = "Error"
      render 'index'
    end
  end

  def update
#   @new_item = MenuItem.new
#   @menu_item = MenuItem.find(params[:id])
#   attrs = params[:menu_item]
#   attrs[:category] = attrs[:category].capitalize
#   if @menu_item.update_attributes(attrs)
#     flash[:success] = "Successful change"
#     redirect_to menu_path(:id => @menu_item.id)
#   else
      @head = "Error"
      render 'index'
#   end
  end

  def show
    @menu_item = MenuItem.find(params[:id])
    flash[:notice] = "you prolly didn't mean to come here";
    redirect_to menu_path(@menu_item)
  end

  def edit
    redirect_to menu_path
  end

  def destroy
    item = MenuItem.find(params[:id])
    category = Category.find(item.category_id)
    item.destroy
    category.destroy if category.menu_items.count == 0
    
    flash[:success] = "#{item.name} deleted"
    redirect_to menu_path
  end

  def home
    @head = "Moto Cafe"
  end

  def toggle_stock 
    @menu_item = MenuItem.find(params[:id])
    @menu_item.toggle_stock
    @menu_item.save
    render(:update) {|page|
      page << "$('#in_stock_#{params[:id]}').attr('class','#{@menu_item.out_of_stock ? "disabled" : "in_stock"}')"
      page << "$('#out_of_stock_#{params[:id]}').attr('class','#{@menu_item.out_of_stock ? "out_of_stock" : "disabled"}')"
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
        page << "$('##{@swap_item.id}').find('input').val('#{@swap_item.display_order}')"
        page << "$('##{@menu_item.id}').swap('##{@swap_item.id}')"
      }
    end
  end
end
