class ShopCategory < ActiveRecord::Base
  default_scope :order => 'name'
  
  acts_as_tree
  
  has_and_belongs_to_many :shops
end
