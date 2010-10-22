require 'test_helper'

class CauseTest < ActiveSupport::TestCase
  
  test "should create voted cause" do
    cause = Cause.make_with_votes :votes_count => 5
    assert_equal 5, cause.votes.count
  end

  test "should increase vote counter" do
    cause = Cause.make :status => :active
    assert_equal 0, cause.votes_count
    
    cause.votes.make
    cause.reload
    assert_equal 1, cause.votes_count
  end

  test "should increase charity funds raised" do
    charity = Charity.make :funds_raised => 20
    cause = Cause.make :status => :raising_funds, :funds_needed => 100, :charity => charity, :funds_raised => 10
    
    assert_equal 30, charity.reload.funds_raised
    
    cause.funds_raised += 50
    assert cause.save
    
    assert_equal 60, cause.funds_raised
    assert_equal 80, charity.reload.funds_raised
  end
  
  test "should decrease charity funds raised" do
    charity = Charity.make :funds_raised => 20
    cause = Cause.make :status => :raising_funds, :funds_needed => 100, :charity => charity, :funds_raised => 100
    
    cause.funds_raised -= 50
    assert cause.save
    
    assert_equal 50, cause.funds_raised
    assert_equal 70, charity.reload.funds_raised    
  end
  
  test "should decrease charity funds raised when cause deleted" do
    charity = Charity.make :funds_raised => 150
    cause = Cause.make :status => :raising_funds, :funds_needed => 100, :charity => charity, :funds_raised => 50
    
    cause.destroy
    
    assert_equal 0, Cause.count   
    assert_equal 150, charity.reload.funds_raised    
  end

end
