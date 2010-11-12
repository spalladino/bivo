class Income < Transaction
  belongs_to :income_category
  belongs_to :shop
  
  validates_presence_of :income_category_id
  validates_presence_of :shop_id, :if => :category_is_shop?
  
  after_save :process_income
  
  def category_is_shop?
    self.income_category_id == IncomeCategory.get_shop_category.id
  end

  def self.founds_raised(from, to)
    Income.where("transaction_date BETWEEN ? AND ?", from, to).sum("amount")
  end
  
  def process_income
    if !self.category_is_shop?
      Account.investments_account.accept_investment self
    end
  end
end
