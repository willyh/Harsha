class AddDisplayOrderToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :display_order, :integer
  end

  def self.down
    remove_column :categories
  end
end
