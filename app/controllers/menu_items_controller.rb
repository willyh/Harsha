class MenuItemsController < ApplicationController
  before_filter :authorize, :except =>  [:show, :home]
  def index
    @new_item = MenuItem.new
    @menu_item = @new_item
    @head = "Check Out Your Menu"
  end

  def create
    #@menu_item and @new_item will be the same unless returning from
    #a failed update then new_item will be new and
    #menu_item will be the item that failed to update
    attrs = params[:menu_item]
    @new_item = MenuItem.new(attrs)
    @new_item.category = @new_item.category.capitalize || "Other"
    if @new_item.save
      redirect_to menu_path
    else
      @menu_item = @new_item
      @head = "Error"
      render 'index'
    end
  end

  def update
    @new_item = MenuItem.new
    @menu_item = MenuItem.find(params[:id])
    if @menu_item.update_attributes(params[:menu_item])
      redirect_to menu_path
    else
      @head = "Error"
      render 'index'
    end
  end

  def show
    @menu_item = MenuItem.find(params[:id])
    @head = "#{@menu_item.name}"
  end

  def edit
    redirect_to menu_path
    @new_item = MenuItem.new
    @menu_item = MenuItem.find(params[:id])
    @head = "Check Out Your Menu!"
  end

  def destroy
    category = MenuItem.find(params[:id]).category
    MenuItem.find(params[:id]).destroy
    redirect_to menu_path
  end

  def home
    @head = "Moto Cafe"
  end

  def sold_out
    @order = MenuItem.find(params[:id])
    @order.sold_out
    @order.save
    redirect_to menu_path
  end
end
