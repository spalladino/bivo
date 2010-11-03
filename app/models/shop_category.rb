class ShopCategory < ActiveRecord::Base
  acts_as_tree
  has_many :shops, :through => :category_shops
end
