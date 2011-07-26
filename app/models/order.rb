class Order < ActiveRecord::Base
  attr_accessor :item_addition
  attr_accessible :customer_name, :pickup_time, :price, :items

  validates :items,	:presence => true

 # validates :customer_name, :presence => true

  validates :pickup_time, :uniqueness => true, :format => { :with => /\d:\d/ }

  def format_price price
    if price.to_s =~ /\d*[.]\d{2,}/
      "$#{price}"
    else
      "$#{price}0"
    end
  end

  def update_price
puts "updating price"
    arr = items.split("\n")
    arr.each do |item|
      self.update_attributes(:price => price + MenuItem.find_by_name(item))
    end
  end

  def add_items hash
    item = hash["item_addition"]
    if item
      arr =item.split(" ")
      item_price = arr.delete_at(0).to_f
      hash[:price] = self.price + item_price
      hash[:items] = (self.items || "") + format_price(item_price) + " " + arr.join(" ")+ "\n"
    end
    hash
  end
  

end
