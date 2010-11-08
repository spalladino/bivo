class IncomeCategory < ActiveRecord::Base
  
  validates_presence_of :name
  
  has_many :incomes
  
  ShopName = 'shop'
  
  def self.get_shop_category
    @@shop ||= self.find_by_name ShopName
  end

end
