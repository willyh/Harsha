class Option < ActiveRecord::Base
  has_and_belongs_to_many :menu_items
  has_and_belongs_to_many :selections

  after_initialize :init

  def init
    self.price ||= 0
    self.out_of_stock ||= false
  end

  def toggle_stock
    self.out_of_stock = ! self.out_of_stock
  end
end
