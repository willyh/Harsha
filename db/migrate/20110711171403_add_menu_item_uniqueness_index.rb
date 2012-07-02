class AddMenuItemUniquenessIndex < ActiveRecord::Migration
  def self.up
    add_index :menu_items, :name, :unique => true
  end

  def self.down
    remove_index :menu_items, :name
  end
end
