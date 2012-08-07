class Selection < ActiveRecord::Base
  belongs_to :order
  belongs_to :menu_item
  has_and_belongs_to_many :options
	
	def price
		p = menu_item.price
		options.each do |o|
			p += o.price
		end
		p
	end
end
