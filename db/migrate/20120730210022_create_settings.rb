class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.datetime :opens_at
      t.datetime :closes_at
      t.string :home_page_text

      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
