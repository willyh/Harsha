class MenuItem < ActiveRecord::Base
  attr_accessible :name, :price, :description

  validates :name, :presence => true,
		:uniqueness => { :case_sensitive => false }
# need to reject duplicate names

  validates :price, 	:presence 	=> true

  validates_numericality_of 	:price,
				:only_float => true,
				:message => "must be a number"
end
