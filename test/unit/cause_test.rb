require 'test_helper'

class CauseTest < ActiveSupport::TestCase
  
  test "should create voted cause" do
    cause = Cause.make_with_votes :votes_count => 5
    assert_equal cause.votes.count, 5
  end

  test "new category has inactive status" do
    cause = Cause.make
    assert_equal cause.status, :inactive
  end

  test "should increase vote counter" do
    cause = Cause.make :status => :active
    assert_equal 0, cause.votes_count
    
    cause.votes.make
    cause.reload
    assert_equal 1, cause.votes_count
  end

end
