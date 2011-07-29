class Order < ActiveRecord::Base
  attr_accessible :customer_name, :pickup_time, :price, :items, :instructions

  validates :items,	:presence => true

  validates :pickup_time, :uniqueness => true, :format => { :with => /\d:\d/ }

  before_create :update_price

  def paypal_url(return_url, notify_url)
    values = {
      :business => 'willyh_1311952951_per@gmail.com',
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :invoice => id,
      :no_shipping => 1,
      :no_note => 1,
      :notify_url => notify_url
    }
    arr = items.split("\n")
    arr.each_with_index do |item_name, index|
        item = MenuItem.find_by_name(item_name)
      values.merge!({
        "amount_#{index+1}" => item.price,
        "item_name_#{index+1}"=> item.name,
        "item_number_#{index+1}" => item.id,
        "quantity_#{index+1}" => 1
      })
    end
    "https://www.sandbox.paypal.com/cgi-bin/webscr?"+values.map {|k,v|"#{k}=#{v}" }.join("&")
  end

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
  
  def complete
    self.completed = true
    self.save
  end

  def complete_admin? admin
    self.completed = true
    self.save(!admin)
  end

  def print
# change this when i get a printer
# also get rid of complete_admin?
    self.complete_admin?(true)
  end

end

