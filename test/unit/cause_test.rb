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
  
  test "should mark as deleted" do
    cause = Cause.make :status => :raising_funds
    cause.destroy
    assert_equal :deleted, cause.reload.status, "Status is not deleted"
  end
  
  test "should delete from database" do
    cause = Cause.make :status => :active
    id = cause.id
    cause.destroy
    
    assert_nil Cause.find_deleted(id), "Cause not deleted from db"
  end
  
  test "should not retrieve deleted causes on default scope" do
    causes = Cause.make_many 2, :status => :raising_funds
    id = causes.last.id

    causes.first.destroy
    assert_equal 1, Cause.count, "Deleted cause is retrieved"
    assert_equal id, Cause.first.id, "Cause id does not match"
    
    assert_equal 2, Cause.with_deleted {count}, "Deleted cause is not retrieved with exclusive scope"
  end

end
