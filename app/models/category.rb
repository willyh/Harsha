class Category < ActiveRecord::Base
  has_many :menu_items, :order => "display_order ASC"

  validates :name, :presence => true,
                  :uniqueness => true
  default_scope :order => "display_order ASC"
end
