class MenuItemsController < ApplicationController
  before_filter :authorize, :except =>  [:index, :show, :home]
  def index
    @menu_items = MenuItem.all
    @menu_item = MenuItem.new 
    @head = params[:category] || "Menu"
  end

  def create
    @menu_item = MenuItem.new(params[:menu_item])
    @menu_item.category = @menu_item.category.capitalize || "Other"
    if @menu_item.save
      redirect_to menu_path :category => @menu_item.category
    else
      @menu_items = MenuItem.all
      render 'index'
    end
  end

  def show
    @menu_item = MenuItem.find(params[:id])
    @head = "#{@menu_item.name}"
  end

  def edit
    @menu_items = MenuItem.all.sort{ |x,y| x.id<=>y.id }
    @menu_item = MenuItem.find(params[:id])
    @head = "Edit #{@menu_item.name}"
  end

  def update
    @menu_item = MenuItem.find(params[:id])
    if @menu_item.update_attributes(params[:menu_item])
      redirect_to menu_path :category => @menu_item.category
    else
      @menu_items = MenuItem.all
      render 'edit'
    end
  end

  def destroy
    category = MenuItem.find(params[:id]).category
    MenuItem.find(params[:id]).destroy
    redirect_to menu_path :category => category
  end

  def home
    @head = "Moto Cafe"
  end

  def sold_out
    @order = MenuItem.find(params[:id])
    @order.sold_out
    @order.save
    redirect_to menu_items_path :category => @order.category
  end
end
