class Order < ActiveRecord::Base
  attr_accessible :customer_name, :pickup_time, :price, :items, :instructions

  validates :items,	:presence => true

  validates :pickup_time, :uniqueness => true, :format => { :with => /\d:\d/ }

  before_create :update_price

  def format_price price
    if price.to_s =~ /\d*[.]\d{2,}/
      "$#{price}"
    else
      "$#{price}0"
    end
  end

  def update_price
    p = 0
    arr = self.items.split("\n")
    arr.each do |item|
      p += MenuItem.find_by_name(item).price
    end
    self.price = p
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

