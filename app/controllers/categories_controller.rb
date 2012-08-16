class CategoriesController < ApplicationController
	before_filter :authorize

  def change_order
      @category = Category.find(params[:id])
      @swap_item = Category.find_by_display_order(params[:display_order])
			unless(params[:display_order].blank?)
				unless(@category.display_order.nil? || @swap_item.nil?)
					temp = @category.display_order
					@swap_item.display_order = temp
					@swap_item.save
				end
				@category.display_order = params[:display_order]
				@category.save
			end

      render(:update) {|page|
        page.replace_html 'item_list', :partial => 'menu_items/item_list', :locals => {:@categories => Category.all, :@options => @options, :@menu_item => @menu_item}
        page << 'window.scrollTo(0,0)'
        page << 'fixFocusForMobile()'
        page << 'bindListElements()'
        page << 'addDisplayOrderListeners()'
      }
  end
	def update
		@category = Category.find(params[:id])
		old_name = @category.name
		name = params[:category][:name]
		if (name == @category.name)
			flash[:notice] = "#{@category.name} was unaffected"
		elsif name.blank?
			flash[:error] = "Category name cannot be blank"
		elsif !Category.find_by_name(name).nil?
			flash[:error] = "'#{name}' is already taken"
		else
			@category.update_attributes( :name => name )
			flash[:success] = "'#{old_name}' has been changed to '#{name}'"
		end
			redirect_to new_menu_item_path
	end

  def destroy
    category = Category.find(params[:id])
		name = category.name
		if category.menu_items.count == 0
			category.destroy
    
			flash[:success] = "'#{name}' deleted"
			redirect_to new_menu_item_path
		end
  end
end
