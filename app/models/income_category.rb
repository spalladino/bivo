class IncomeCategory < ActiveRecord::Base
  
  validates_presence_of :name
  
  has_many :incomes
  
  ShopName = 'shop'
  
end
