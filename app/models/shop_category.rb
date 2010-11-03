class ShopCategory < ActiveRecord::Base
  default_scope :order => 'name'
  
  acts_as_tree
  has_many :shops, :through => :category_shops
end
