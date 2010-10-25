require 'test_helper'

class CharityTest < ActiveSupport::TestCase

  test "should get charities with cause data" do
    charity = Charity.make
    [20,10,40].each do |votes| 
      Cause.make_with_votes :votes_count => votes, :charity => charity, :funds_raised => 100.0
    end
    
    charities = Charity.with_cause_data.all
    assert_not_nil charities
    assert_equal 1, charities.size
    assert_equal charity.id, charities.first.id
    assert_equal 70, charities.first.votes_count.to_i
    assert_equal 3, charities.first.causes_count.to_i
    assert_equal 300, charities.first.total_funds_raised.to_i
  end

end
