class AddSecretToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :secret, :string
  end

  def self.down
    remove_column :orders, :completed
  end
end
