class AddLastActivationToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :last_activation_date, :datetime
  end

  def self.down
    remove_column :settings, :last_activation_date
  end
end
