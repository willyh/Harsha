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
    @new_item.out_of_stock = true
    if @new_item.save
      flash[:success] = "#{@new_item.name} successfully added to menu!"
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
    attrs = params[:menu_item]
    attrs[:category] = attrs[:category].capitalize
    @menu_item.category = @menu_item.category.capitalize || "Other"
    if @menu_item.update_attributes(attrs)
      flash[:success] = "Successful change"
      redirect_to menu_path(id: @menu_item.id)
    else
      @head = "Error"
      render 'index'
    end
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
    item.destroy
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
    flash[:success] = "Successful change"
    redirect_to menu_path(id: @menu_item.id)
  end
end
