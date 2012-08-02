class Option < ActiveRecord::Base
  belongs_to :menu_item

  after_initialize :init

  def init
    self.price ||= 0
    self.out_of_stock ||= false
  end

  def toggle_stock
    self.out_of_stock = ! self.out_of_stock
  end
end
