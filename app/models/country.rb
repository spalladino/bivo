class Country < ActiveRecord::Base
  
  has_many :causes
  has_many :charities
  
  validates_presence_of :name
  
end
