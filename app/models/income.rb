class Income < Transaction
  belongs_to :income_category
  belongs_to :shop
  
  validates_presence_of :income_category_id
  validates_presence_of :shop_id, :if => :category_is_shop?
  
  after_save :process_income
  
  def category_is_shop?
    self.income_category_id == IncomeCategory.get_shop_category.id
  end
  
  def process_income
    if !self.category_is_shop?
      Account.investments_account.accept_investment self
    else
      Account.shop_account(self.shop).accept_income self
    end
  end

  def detail
    if (shop.nil?)
      ""
    else
      shop.name
    end
  end
  
  def revenue_amount
    Income.to_revenue amount
  end
  
  def self.to_revenue(value)
    0.05.to_d * value
  end

  def self.between(from, to)
    where("transaction_date BETWEEN ? AND ?", from, to)
  end

  def self.funds_raised(from, to)
    between(from, to).sum("amount")
  end

  def self.transactions_count(from, to)
    between(from, to).count
  end
end
