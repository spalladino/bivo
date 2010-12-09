class InvestmentsAccount < Account
  NAME = 'Investments'
  
  def accept_investment(income)
    Account.transfer self, Account.cash_pool_account, income.amount, "investment #{income.id}", income
  end
end
