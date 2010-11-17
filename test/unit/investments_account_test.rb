require 'test_helper'

class InvestmentsAccountTest < ActiveSupport::TestCase

  test "create investments account" do
    assert_difference('InvestmentsAccount.count') do
      a = Account.investments_account
      assert_instance_of InvestmentsAccount, a
      assert_equal 0.to_d, a.balance
      assert_equal InvestmentsAccount::NAME, a.name
    end
  end
  
  test "creating investment moves total amount to cash pool" do
    income = Income.create! :input_amount => 100, :input_currency => Transaction::DefaultCurrency, :user => Admin.make, :transaction_date => Date.today, :income_category => IncomeCategory.make
    investment_movement = Account.investments_account.movements.first
    cash_pool_movement = Account.cash_pool_account.movements.first
    
    assert_movement -100, -100, investment_movement
    assert_movement 100, 100, cash_pool_movement
    
    assert_equal income, investment_movement.transaction
    assert_equal income, cash_pool_movement.transaction
  end
end
