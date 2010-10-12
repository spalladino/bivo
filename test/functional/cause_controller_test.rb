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
    (1..100).each { |i| Cause.make_with_votes :votes_count => i, :status => :active }
    
    first_20 = Cause.where()
    
    get :index
    
    assert_not_nil assigns(:causes)
    assert_not_nil assigns(:causes)
  end
  
end




#    * :success - Status code was 200
#    * :redirect - Status code was in the 300-399 range
#    * :missing - Status code was 404
#    * :error - Status code was in the 500-599 range
