class AddOutOfStockToMenuItems < ActiveRecord::Migration
  def self.up
    add_column :menu_items, :out_of_stock, :boolean
  end

  def self.down
    remove_column :menu_items, :out_of_stock
  end
end
