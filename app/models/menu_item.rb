class MenuItem < ActiveRecord::Base
  attr_accessible :name, :price, :description, :category, :photo

  has_attached_file :photo,
    :styles => {
      :small => "160x",
      :medium => "380x300",
      :large => "640x500" }

  validates :name, :presence => true,
		:uniqueness => { :case_sensitive => false }

  validates :price, 	:presence 	=> true

  validates_numericality_of 	:price,
				:only_float => true,
				:message => "must be a number"
  validates :category, :presence => true

  def toggle_stock
    self.out_of_stock = !self.out_of_stock
  end

end
