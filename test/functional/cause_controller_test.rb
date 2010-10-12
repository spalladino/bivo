require 'test_helper'

class CauseControllerTest < ActionController::TestCase
  
  test "should get details" do
    cause = Cause.make :url => "foobar"
    
    get :details, {'url' => "foobar"} 
    
    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_response :success
  end
  
  
  test "should get causes fist page" do
    #    causes = Cause.make(100)
    #    first_20 = Cause.all[0...20]
    #    
    #    get :index
    #    
    #    assert_not_nil assigns(:causes)
    #    assert_not_nil assigns(:causes)
  end
  
  
  test "should get voting causes first page sorted by popularity" do
   (1..100).each { |i| Cause.make_with_votes :votes_count => i, :status => :active }
    
    first_20 = Cause.where()
    
    get :index
    
    assert_not_nil assigns(:causes)
    assert_not_nil assigns(:causes)
  end
  
  
  test "should fail on vote if already voted (ajax)" do
    user = create_user
    user.confirm!
    sign_in user
    
    existing_vote = Vote.find(:first)
    votes_count = Vote.length
    
    xhr :post, :vote, :cause_id => existing_vote.cause_id
    
    assert_equal votes_count,Vote.length
    #deberia testear que se produce un error?
    
  end
  
  
  test "should fail on vote if not authenticated user (no ajax)" do
    cause = Cause.make
    cause_counter = cause.votes.length
    
    post :vote, {'cause_id' => cause.id.to_s} 
    cause.reload
    
    assert_equal cause_counter,cause.votes.length
    #deberia testear que se produce un error?
  end 
  
  
  test "should fail on vote if cause status doesnt support voting (ajax)" do
    
  end
  
  
  test "votes should persist in database if everything is ok (ajax)" do
    user = create_user
    user.confirm!
    sign_in user
    cause = Cause.make
    
    xhr :post, :vote, :cause_id => cause.id
    
    cause.reload
    
    assert_not_equal Vote.find_by_cause_id_and_user_id(cause.id, user.id), nil
  end
  
  
  test "votes should persist in database if everithing is ok (no ajax) " do
    user = create_user
    user.confirm!
    sign_in user
    cause = Cause.make
    cause_counter = cause.votes.length
    
    cause.reload
    
    assert_not_equal Vote.find_by_cause_id_and_user_id(cause.id, user.id), nil   
  end
  
  
  test "votes of the cause should be incremented by one if everthing worked (no ajax)" do
    user = create_user
    user.confirm!
    sign_in user
    cause = Cause.make
    cause_counter = cause.votes.length
    
    post :vote, {'cause_id' => cause.id.to_s} 
    cause.reload
    
    assert_equal cause_counter+1,cause.votes.length
  end    
end



#    * :success - Status code was 200
#    * :redirect - Status code was in the 300-399 range
#    * :missing - Status code was 404
#    * :error - Status code was in the 500-599 range
