class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.string :name
      t.float :price
      t.boolean :out_of_stock
      t.integer :menu_item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :options
  end
end
