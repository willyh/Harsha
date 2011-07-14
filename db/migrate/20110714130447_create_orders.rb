class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :pickup_time
      t.string :customer_name
      t.string :items
      t.float :price

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
