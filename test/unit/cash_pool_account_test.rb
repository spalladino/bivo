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
  
  def make_raising_causes(*causes_spec)
    result = []
    causes_spec.each do |spec|
      result << Cause.make(:status => :active, :funds_needed => 100, :funds_raised => 0)
      Vote.make_many (spec[:votes] || 1), :cause => result.last
      result.last.status = :raising_funds
      result.last.save!
    end
    
    result
  end
  
  def add_cash_pool_income(amount)    
    Account.transfer Account.make, Account.cash_pool_account, amount.to_d
  end
      
  test "split funds between raising funds causes" do    
    c1, c2 = make_raising_causes({}, {})
    add_cash_pool_income 50
    
    c1.reload
    c2.reload
    
    assert_equal 25, c1.funds_raised
    assert_equal 25, c2.funds_raised
  end
  
  test "split funds between causes according to votes" do
    c1, c2 = make_raising_causes({:votes => 2}, {:votes => 1})
    add_cash_pool_income 90
    
    c1.reload
    c2.reload
    
    assert_equal 60, c1.funds_raised
    assert_equal 30, c2.funds_raised
  end
end
