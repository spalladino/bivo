class ShopAccount < Account
  belongs_to :shop
  
  def accept_income(income)
    # this way we ensure that:
    #   cash_pool_amount + cash_reserves_amount == income.amount
    cash_pool_amount = (0.95 * income.amount.to_d).to_d
    cash_reserves_amount = income.amount.to_d - cash_pool_amount
    
    Account.transfer self, Account.cash_pool_account, cash_pool_amount, "shop income #{income.id}", income
    Account.transfer self, Account.cash_reserves_account, cash_reserves_amount, "shop income #{income.id}", income
  end
end
