class CreateSelections < ActiveRecord::Migration
  def self.up
    create_table :selections do |t|
      t.integer :order_id
      t.integer :menu_item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :selections
  end
end
