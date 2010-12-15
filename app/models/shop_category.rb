class ShopCategory < ActiveRecord::Base
  default_scope :order => "lower(#{ShopCategory.table_name}.name)"
  
  translate :translate => [:name], \
            :index => [:name]
  
  acts_as_tree :order => 'lower(name)'
  
  has_and_belongs_to_many :shops
  
  validates_presence_of :name
end
