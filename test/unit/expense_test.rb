require 'test_helper'

class ExpenseTest < ActiveSupport::TestCase
  
  test "can make" do
    Expense.make
  end
  
  test "expense_between filters by transaction_date" do
    a = Expense.make :transaction_date => 2.months.ago
    b = Expense.make :transaction_date => 1.week.ago
    
    expenses = Expense.between(1.month.ago, Date.today)
    
    assert_equal [b], expenses
  end
end