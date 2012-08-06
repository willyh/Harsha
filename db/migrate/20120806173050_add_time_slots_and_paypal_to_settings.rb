class AddTimeSlotsAndPaypalToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :paypal_email, :string
    add_column :settings, :interval, :integer
    add_column :settings, :max_per_slot, :integer
  end

  def self.down
    remove_column :settings, :paypal_email
    remove_column :settings, :interval
    remove_column :settings, :max_per_slot
  end
end
