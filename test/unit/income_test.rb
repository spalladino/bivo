require 'test_helper'

class IncomeTest < ActiveSupport::TestCase
  
  test "can make" do
    Income.make :shop
  end
  
  test "income_between filters by transaction_date" do
    a = Income.make :shop, :transaction_date => 2.months.ago
    b = Income.make :shop, :transaction_date => 1.week.ago
    
    incomes = Income.between(1.month.ago, Date.today)
    
    assert_equal [b], incomes
  end
  
  test "revenue_amount is 5% of amount" do
    a = Income.make :shop, :input_amount => 100
    assert_equal 5, a.revenue_amount 
  end
end