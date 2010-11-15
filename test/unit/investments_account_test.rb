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
    # TODO assert movements are associated with Income
    Income.create! :amount => 100, :user => Admin.make, :transaction_date => Date.today, :income_category => IncomeCategory.make
    assert_movement -100, -100, Account.investments_account.movements.first
    assert_movement 100, 100, Account.cash_pool_account.movements.first
  end
end
