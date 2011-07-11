class MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.all
    @menu_item = MenuItem.new
  end

  def create
    @menu_item = MenuItem.new(params[:menu_item])
    if @menu_item.save
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
