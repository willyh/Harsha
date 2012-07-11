class AddDisplayOrderToMenuItems < ActiveRecord::Migration
  def self.up
    add_column :menu_items, :display_order, :integer
  end

  def self.down
    remove_column :menu_items, :display_order
  end
end
