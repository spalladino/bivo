require 'test_helper'

class CauseControllerTest < ActionController::TestCase
  
  test "should get details" do
    cause = Cause.make :url => "foobar"
    
    get :details, {'url' => "foobar"} 
    
    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_response :success
  end
  
  test "should get voting causes first page sorted by popularity" do
    # Create 20 causes with votes and 40 unvoted
    (1..20).each { |i| Cause.make_with_votes :votes_count => i, :status => :active }
    40.times { Cause.make :status => :active}
    
    # Fetch the voted ones, sorted by vote count
    causes_with_votes_ids = Cause.where("votes_count > ?", 0).map(&:id).reverse
    
    get :index
    
    assert_not_nil assigns(:causes)
    assert_equal 20, assigns(:causes).size
    assert_equal causes_with_votes_ids, assigns(:causes).map(&:id)
  end
  
end

