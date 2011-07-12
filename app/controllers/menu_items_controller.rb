class MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.all
    @menu_item = MenuItem.new
  end

  def create
    @menu_item = MenuItem.new(params[:menu_item])
    @menu_item.category = "Other" if @menu_item.category.blank?
    if @menu_item.save
      MenuItem.categories << @menu_item.category
      redirect_to display_path
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
      MenuItem.categories << @menu_item.category
      redirect_to display_path
    else
      @menu_items = MenuItem.all
      render 'edit'
    end
  end

  def destroy
    MenuItem.find(params[:id]).destroy
    redirect_to display_path
  end
end
