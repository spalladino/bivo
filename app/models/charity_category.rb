class CharityCategory < ActiveRecord::Base
  
  validates_presence_of :name
  
  has_many :charities
  
end
