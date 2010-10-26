class Income < Transaction
  belongs_to :income_category
  belongs_to :shop
  
  validates_presence_of :income_category_id
  validates_presence_of :shop_id, :if => :category_is_shop?
  
  def category_is_shop?
    @category = IncomeCategory.find_by_name IncomeCategory::ShopName
    self.income_category_id == @category.id
  end
end