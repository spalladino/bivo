class ExpensesAccount < Account
  NAME = 'Expenses'
  
  def accept_expense(expense)
    Account.transfer Account.cash_reserves_account, self, expense.amount, "expense #{expense.id}", expense
  end
end
