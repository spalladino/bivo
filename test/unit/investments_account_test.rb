require 'test_helper'

class InvestmentsAccountTest < ActiveSupport::TestCase

  test "investment income blueprint works" do
    income = Income.make(:investment)
    assert_not_equal IncomeCategory.get_shop_category.id, income.income_category_id
    assert_nil income.shop
  end

  test "create investments account" do
    assert_difference('InvestmentsAccount.count') do
      a = Account.investments_account
      assert_instance_of InvestmentsAccount, a
      assert_equal 0.to_d, a.balance
      assert_equal InvestmentsAccount::NAME, a.name
    end
  end
  
  test "creating investment moves total amount to cash reserves" do
    income = Income.make :investment, :input_amount => 100
    investment_movement = Account.investments_account.movements.first
    cash_reserves_movement = Account.cash_reserves_account.movements.first
    
    assert_movement -100, -100, investment_movement
    assert_movement 100, 100, cash_reserves_movement
    
    assert_equal income, investment_movement.transaction
    assert_equal income, cash_reserves_movement.transaction
  end
end
