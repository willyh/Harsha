class Post < ActiveRecord::Base
  validates :question, :presence => true
  validates :response, :presence => true

  default_scope :order => "updated_at DESC"
end
