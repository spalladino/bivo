class ShopAccount < Account
  belongs_to :shop
  
  def accept_income(income)
    cash_pool_amount = (0.95 * income.amount.to_d).to_d
    Account.transfer self, Account.cash_pool_account, cash_pool_amount, "shop income #{income.id}", income
  end
end
