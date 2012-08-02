class Option < ActiveRecord::Base
  belongs_to :menu_item

  after_initialize :init

  def init
    self.price = 0 if self.price.nil?
    self.out_of_stock = false
  end
end
