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
  
  setup do
    CauseCategory.all.map &:destroy
    @cause_categories = CauseCategory.make_many 3
  end

  def make_active_causes(causes_spec)
    result = []
    causes_spec.each_with_index do |spec, index|
      result << Cause.make(:cause_category => @cause_categories[index], :status => :active, :funds_needed => 100, :funds_raised => 0)
      Vote.make_many (spec[:votes] || 1), :cause => result.last
    end    
    result
  end
  
  def make_raising_causes(causes_spec)
    result = self.make_active_causes causes_spec
    result.each do |cause|
      cause.status = :raising_funds
      cause.save!      
    end
    result
  end
    
  def add_cash_pool_income(amount)    
    Account.transfer Account.make, Account.cash_pool_account, amount.to_d
  end
      
  test "split funds between raising funds causes" do    
    c1, c2 = make_raising_causes [{}, {}]
    add_cash_pool_income 50
    
    c1.reload
    c2.reload
    
    assert_equal 25, c1.funds_raised
    assert_equal 25, c2.funds_raised
  end
  
  test "split funds between causes according to votes" do
    c1, c2 = make_raising_causes [{:votes => 2}, {:votes => 1}]
    add_cash_pool_income 90
    
    c1.reload
    c2.reload
    
    assert_equal 60, c1.funds_raised
    assert_equal 30, c2.funds_raised
  end
  
  test "take care of rounded currency amounts. always split everything" do
    c1, c2 = make_raising_causes [{:votes => 2}, {:votes => 1}]
    add_cash_pool_income 100
    
    c1.reload
    c2.reload
    
    assert_equal 100, c1.funds_raised + c2.funds_raised
    assert_equal 0, Account.cash_pool_account.balance
  end
  
  test "do not transfer more than it is needed" do
    c1, c2 = make_raising_causes [{}, {}]
    add_cash_pool_income 300
    c1.reload
    c2.reload
    
    assert_equal c1.funds_needed, c1.funds_raised
    assert_equal c2.funds_needed, c2.funds_raised
    assert_equal :completed, c1.status
    assert_equal :completed, c2.status
    assert_equal 100, Account.cash_pool_account.balance
  end
  
  test "allow second round" do
    r1, r2 = make_raising_causes [{},{}]
    a1, a2 = make_active_causes [{},{}]
    
    add_cash_pool_income 300
    a1.reload
    a2.reload
    
    assert_equal :raising_funds, a1.status
    assert_equal :raising_funds, a2.status
    assert_equal 50, a1.funds_raised
    assert_equal 50, a2.funds_raised
  end
  
  test "allow third round" do
    r1, r2 = make_raising_causes [{},{}]
    a1, a2 = make_active_causes [{:votes => 2},{:votes => 2}]
    b1, b2 = make_active_causes [{},{}]
    
    add_cash_pool_income 500
    b1.reload
    b2.reload
    
    assert_equal :raising_funds, b1.status
    assert_equal :raising_funds, b2.status
    assert_equal 50, b1.funds_raised
    assert_equal 50, b2.funds_raised
  end
  
  test "always use votes" do
    r1, r2 = make_raising_causes [{:votes => 1},{:votes => 4}]
    a1, a2 = make_active_causes [{},{:votes => 2}]
    
    add_cash_pool_income 200
    [r1, r2, a1, a2].map &:reload
    
    assert_equal :raising_funds, r1.status
    assert_equal :completed, r2.status
    assert_equal :active, a1.status
    assert_equal :raising_funds, a2.status
    
    assert_equal 60, r1.funds_raised
    assert_equal 100, r2.funds_raised
    assert_equal 40, a2.funds_raised
  end
end
