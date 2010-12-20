require 'test_helper'

class ExpensesAccountTest < ActiveSupport::TestCase

  test "create expenses account" do
    assert_difference('ExpensesAccount.count') do
      a = Account.expenses_account
      assert_instance_of ExpensesAccount, a
      assert_equal 0.to_d, a.balance
      assert_equal ExpensesAccount::NAME, a.name
    end
  end

  test "saving expense moves from reserves to expeses account" do
    expense = Expense.make :input_amount => 40    
    account = Account.expenses_account
    reserves = Account.cash_reserves_account
    
    assert_equal 40.to_d, account.balance
    assert_equal -40.to_d, reserves.balance
    
    assert_movement 40, 40, account.movements.first
    assert_movement -40, -40, reserves.movements.first
    
    assert_equal 1, account.movements.count
    assert_equal 1, reserves.movements.count
    
    assert_equal expense, account.movements.first.transaction
  end
end