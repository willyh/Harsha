class MenuItem < ActiveRecord::Base
  attr_accessible :name, :price, :description

  validates :name, :presence => true
# need to reject duplicate names

  validates :price, 	:presence 	=> true

  validates_numericality_of :price, :only_float => true, :message => "can only be a number"
end
