class CategoriesController < ApplicationController
  def change_order
    unless(params[:display_order].nil?)
      @category = Category.find(params[:id])
      @swap_item = Category.find_by_display_order(params[:display_order])
      unless(@category.display_order.nil? || @swap_item.nil?)
        temp = @category.display_order
        @swap_item.display_order = temp
        @swap_item.save
      end
      @category.display_order = params[:display_order]
      @category.save

      render(:update) {|page|
        page << "$('#c#{@swap_item.id}').find('input').val('#{@swap_item.display_order}')"
      }
    end
  end
end
