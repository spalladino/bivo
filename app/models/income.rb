class Income < Transaction
  belongs_to :income_category
  belongs_to :shop
  
  validates_presence_of :income_category_id
  validates_presence_of :shop_id, :if => :category_is_shop?
  
  def category_is_shop?
    self.income_category_id == IncomeCategory.get_shop_category.id
  end
end