class AddPriceAndStockToOptions < ActiveRecord::Migration
  def self.up
    add_column :options, :price, :float
    add_column :options, :out_of_stock, :bool
  end

  def self.down
    remove_column :options, :price
    remove_column :options, :out_of_stock
  end
end
