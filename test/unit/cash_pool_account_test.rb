require 'test_helper'

class CashPoolAccountTest < ActiveSupport::TestCase

  test "create cash pool account" do
    assert_difference('CashPoolAccount.count') do
      a = Account.cash_pool_account
      assert_instance_of CashPoolAccount, a
      assert_equal 0.to_d, a.balance
      assert_equal CashPoolAccount::NAME, a.name
    end
  end
end
