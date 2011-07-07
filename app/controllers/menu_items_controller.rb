class MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.all
  end

  def create
    @menu_item = MenuItem.new(params[:menu_item])
    if @menu_item.save
      redirect_to @menu_item
#  later change to menu items
    else
      render 'new'
    end
  end

  def new
    @menu_item = MenuItem.new
  end

  def show
    @menu_item = MenuItem.find(params[:id])
  end
end
