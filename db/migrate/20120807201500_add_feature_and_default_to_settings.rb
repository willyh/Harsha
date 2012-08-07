class AddFeatureAndDefaultToSettings < ActiveRecord::Migration
  def self.up
		add_column :settings, :feature, :integer
    add_column :settings, :photo_file_name, :string
    add_column :settings, :photo_content_type, :string
    add_column :settings, :photo_file_size, :integer
    add_column :settings, :photo_updated_at, :datetime
  end

  def self.down
    remove_column :settings, :photo_file_name
    remove_column :settings, :photo_content_type
    remove_column :settings, :photo_file_size
    remove_column :settings, :photo_updated_at
  end
end
