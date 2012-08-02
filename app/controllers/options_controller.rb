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
    flash[:success] = "Deleted #{@option.name}"
    @option.destroy
    redirect_to menu_items_path
  end
  def toggle_stock 
    @option = Option.find(params[:id])
    @option.toggle_stock
    @option.save
    render(:update) {|page|
      page << "jQuery('#in_stock_o#{params[:id]}').attr('class','#{@option.out_of_stock ? "disabled" : "in_stock"}')"
      page << "jQuery('#out_of_stock_o#{params[:id]}').attr('class','#{@option.out_of_stock ? "out_of_stock" : "disabled"}')"
      if !@option.out_of_stock
        page << "jQuery('#o#{params[:id]}').removeClass('dim')"
      else
        page << "jQuery('#o#{params[:id]}').addClass('dim')"
      end
    }
  end
end
