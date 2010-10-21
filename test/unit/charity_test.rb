require 'test_helper'

class CharityTest < ActiveSupport::TestCase

  test "should get charities with votes sum" do
    charity = Charity.make
    [20,10,40].each do |votes| 
      Cause.make_with_votes :votes_count => votes, :charity => charity
    end
    
    charities = Charity.voted.all
    assert_not_nil charities
    assert_equal 1, charities.size
    assert_equal charity.id, charities.first.id
    assert_equal 70, charities.first.votes_count.to_i
  end

end
