class Selection < ActiveRecord::Base
  belongs_to :order
  belongs_to :menu_item
  has_many :options
end
