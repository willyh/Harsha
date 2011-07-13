class Order < ActiveRecord::Base
  attr_accessible :customer_name, :pickup_time, :price, :items

  validates :items, :presence => true

  validates :price, :presence => true

  validates :pickup_time, :presence => true
end
