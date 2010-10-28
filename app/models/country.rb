class Country < ActiveRecord::Base
  
  has_many :causes
  has_many :charities

  has_many :country_shops, :dependent => :destroy
  has_many :shops, :through => :country_shops
  
  validates_presence_of :name
  
end
