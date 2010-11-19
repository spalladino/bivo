require 'test_helper'

class CauseAccountTest < ActiveSupport::TestCase

  test "cause account is created together with cause entity" do
    c = nil
    a = nil
    assert_difference 'CauseAccount.count' do
      c = Cause.make
    end
    
    assert_no_difference 'CauseAccount.count' do
      a = Account.cause_account c
    end
    assert_not_nil a
    assert_equal c, a.cause
    assert_equal 0.to_d, a.balance
    assert_instance_of CauseAccount, a
    assert_equal c.name, a.name
  end
  
  test "upon balance change, update cause funds" do
    c = Cause.make :funds_raised => 0
    a = Account.cause_account c
    
    assert_equal 0, c.funds_raised
    a.balance = 30.to_d
    a.save!
    c.reload
    assert_equal 30, c.funds_raised
  end  

end
