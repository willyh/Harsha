class MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.all
    @menu_item = MenuItem.new 
  end

  def create
    @menu_item = MenuItem.new(params[:menu_item])
    @menu_item.category = @menu_item.category || "Other"
    if @menu_item.save
      redirect_to display_path :category => @menu_item.category
    else
      @menu_items = MenuItem.all
      render 'index'
    end
  end

  def show
    @menu_item = MenuItem.find(params[:id])
  end

  def edit
    @menu_items = MenuItem.all
    @menu_item = MenuItem.find(params[:id])
  end

  def update
    @menu_item = MenuItem.find(params[:id])
    if @menu_item.update_attributes(params[:menu_item])
      redirect_to display_path :category => @menu_item.category
    else
      @menu_items = MenuItem.all
      render 'edit'
    end
  end

  def destroy
    category = MenuItem.find(params[:id]).category
    MenuItem.find(params[:id]).destroy
    redirect_to display_path :category => category
  end
end
