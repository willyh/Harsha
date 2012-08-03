class CreateMenuItemsOptionsJoin < ActiveRecord::Migration
  def self.up
    create_table 'menu_items_options', :id => false do |t|
      t.column 'menu_item_id', :integer
      t.column 'option_id', :integer
    end
  end

  def self.down
    drop_table 'menu_items_options'
  end
end
