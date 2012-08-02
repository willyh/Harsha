class MenuItem < ActiveRecord::Base
  has_many :selections
  has_many :orders, :through => :selections
  has_many :options

  attr_accessible :name, :price, :description, :photo, :display_order

  belongs_to :category

  has_attached_file :photo,
    :styles => {
      :icon => "50x50!",
      :small => "160x",
      :medium => "380x300",
      :large => "640x500" }

  validates :category_id, :presence => true
  validates :name, :presence => true,
		:uniqueness => { :case_sensitive => false }

  validates :price, 	:presence 	=> true

  validates_numericality_of 	:price,
				:only_float => true,
				:message => "must be a number"

  def toggle_stock
    self.out_of_stock = !self.out_of_stock
  end
  
  def available_options
    ops = {}
    Option.all.select{|o| !self.options.include?(o)}.each {|o|
      ops[o.name] = o.id
    }
    return ops
  end

  def free_options
    return self.options.select{|o|
      o.price <= 0
    }
  end

  def non_free_options
    return self.options.select{|o|
      o.price > 0
    }
  end

end
