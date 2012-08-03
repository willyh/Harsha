class CreateSelectionsOptionsJoin < ActiveRecord::Migration
  def self.up
    create_table 'options_selections', :id => false do |t|
      t.column 'option_id', :integer
      t.column 'selection_id', :integer
    end
  end

  def self.down
    drop_table 'options_selections'
  end
end
