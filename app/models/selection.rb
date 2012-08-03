class Selection < ActiveRecord::Base
  belongs_to :order
  belongs_to :menu_item
  has_and_belongs_to_many :options
end
