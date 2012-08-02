class OptionsController < ApplicationController
  before_filter :authorize
  def create
    @categories = Category.all
    @new_item = MenuItem.new
    @menu_item = @new_item

    @option = Option.new(params[:option])
    if @option.name.nil?
      flash[:error] = "Option needs a name"
    elsif @option.save
      flash[:success] = "Created new option #{@option.name}"
    else
      flash[:error] = "Problem creating #{@option.name}"
    end
      redirect_to menu_items_path
  end
  def update
    @option = Option.find(params[:id])
    if @option.update_attributes(params[:option])
      flash[:success] = "Successfully updated #{@option.name}"
    else
      flash[:error] = "Problem updating #{@option.name}"
    end
      redirect_to menu_items_path
  end
  def destroy
    @option = Option.find(params[:id])
    @option.destroy
  end
end
