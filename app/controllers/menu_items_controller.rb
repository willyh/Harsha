class MenuItemsController < ApplicationController
  before_filter :authorize, :except =>  [:show, :home]
  def index
    @menu_item = MenuItem.new 
    @head = "Check Out Your Menu"
  end

  def create
    attrs = params[:menu_item]
    attrs[:category]= params[:new_category] if attrs[:category]=="new_category"
    @menu_item = MenuItem.new(attrs)
    @menu_item.category = @menu_item.category.capitalize || "Other"
    if @menu_item.save
      redirect_to menu_path
    else
      @head = "Error"
      render 'index'
    end
  end

  def update
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
