require 'test_helper'
require 'mocha'

class AccountTest < ActiveSupport::TestCase
  test "Account is created wihout empty balance" do
    a = Account.new :name => 'lorem'
    a.save!
    assert_equal 0.00.to_d, a.balance
  end
  
  test "movements between account affect balance" do
    from, to = Account.make_many(2)

    Account.transfer from, to, 20.to_d

    assert_equal -20.to_d, from.balance
    assert_equal 20.to_d, to.balance

    assert !from.changed?, "account was not saved"
    assert !to.changed?, "account was not saved"
  end
  
  test "movements are recorded with partial balances" do
    a, b, c = Account.make_many(3)
    
    Account.transfer a, b, 20.to_d, "first movement"
    Account.transfer b, c, 5.to_d, "second movement"
    Account.transfer b, c, 10.to_d, "third movement"
    
    assert_equal -20.to_d, a.balance
    assert_equal 5.to_d, b.balance
    assert_equal 15.to_d, c.balance
    
    assert_movement -20, -20, a.movements.first
    assert_movement 20, 20, b.movements.first
    assert_movement -5, 15, b.movements.second
    assert_movement -10, 5, b.movements.third
    assert_movement 5, 5, c.movements.first
    assert_movement 10, 15, c.movements.second
    
    assert_equal "first movement", a.movements.first.description
    assert_equal "first movement", b.movements.first.description
    assert_equal "second movement", b.movements.second.description
    assert_equal "second movement", c.movements.first.description
  end
  
  class RejectAccount < Account
    attr_reader :last_movement
    
    def process(movement)
      @last_movement = movement
      raise 'cancel'
    end
  end
  
  test "exception in process movement reject tranfer" do
    a = Account.make
    b = RejectAccount.create! 'b'
    
    Account.transfer a, b, 10
    
    assert_equal b, b.last_movement.account
    
    assert_equal 0.to_d, a.balance
    assert_equal 0.to_d, b.balance
    assert_equal 0, AccountMovement.count
  end
  
  test "balance at the certain date" do
    from, to = Account.make_many(2)
    
    did(2.month.ago) { Account.transfer(from, to, 20.to_d) }
    did(1.month.ago) { Account.transfer(from, to, 10.to_d) }
    did(2.week.ago) { Account.transfer(from, to, 5.to_d) }

    assert_equal 35.to_d, to.balance_at(Date.today)
    assert_equal 30.to_d, to.balance_at(3.week.ago)
    assert_equal 20.to_d, to.balance_at(6.week.ago)
    assert_equal 0.to_d, to.balance_at(4.month.ago)
  end
  
  private
  
  def did(date)
    now = Time.now
    Time.stubs(:now => date)
    yield
    Time.stubs(:now => now)
    nil
  end
    
end
