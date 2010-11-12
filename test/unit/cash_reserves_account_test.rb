require 'test_helper'

class CashReserveAccountTest < ActiveSupport::TestCase

  test "create cash reserve account" do
    assert_difference('CashReservesAccount.count') do
      a = Account.cash_reserves_account
      assert_instance_of CashReservesAccount, a
      assert_equal 0.to_d, a.balance
      assert_equal CashReservesAccount::NAME, a.name
    end
  end
end
