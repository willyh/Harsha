class AddPickupTimeUniquenessIndex < ActiveRecord::Migration
  def self.up
    add_index :orders, :pickup_time, :unique => true
  end

  def self.down
    remove_index :orders, :pickup_time
  end
end
