require 'test_helper'

class CauseControllerTest < ActionController::TestCase
  
  MESSAGE_OK = "Ok"
  MESSAGE_FAIL_ALREADY_VOTE = "Already voted"
  MESSAGE_FAIL_STATUS_PROBLEM = "The cause status doesnt allow voting"
  MESSAGE_FAIL_AUTH_PROBLEM = "The user should be authenticated"
  
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
  
  
  test "should fail on vote if already voted (ajax) and response is correct" do
    user = create_user
    user.confirm!
    sign_in user
    
    existing_vote = Vote.create :user_id => user.id, :cause_id => 0   
    
    votes_count = Vote.length
    
    xhr :post, :vote, :cause_id => existing_vote.cause_id
    
    #no votes added:
    assert_equal votes_count,Vote.length
    
    #response ok:
    vote_result = JSON.parse(@request.body)
    assert_equal false, vote_result['success']
    assert_equal MESSAGE_FAIL_ALREADY_VOTE, vote_result['message']
  end
  
  
  test "should fail on vote if not authenticated user and error is correct (no ajax)" do
    cause = Cause.make
    cause_counter = cause.votes.length
    
    post :vote, {'cause_id' => cause.id.to_s} 
    cause.reload
    
    #no votes added:
    assert_equal cause_counter,cause.votes.length
    
    #error is correct:
    assert_equal flash[:notice], MESSAGE_FAIL_AUTH_PROBLEM
    assert_response :error
  end 
  
  
  test "should fail on vote if cause status doesnt support voting (ajax)" do
    user = create_user
    user.confirm!
    sign_in user
    cause = Cause.make(:status => "raising_funds")
    
    xhr :post, :vote, :cause_id => cause.id
    
    #response correct:
    vote_result = JSON.parse(@request.body)
    assert_equal false, vote_result['success']
    assert_equal MESSAGE_FAIL_STATUS_PROBLEM, vote_result['message']
    
    #the information doesnt persist:
    assert_nil Vote.find_by_cause_id_and_user_id cause.id, user.id
  end
  
  
  test "votes should persist in database if everything is ok and response is ok(ajax)" do
    user = create_user
    user.confirm!
    sign_in user
    cause = Cause.make
    
    xhr :post, :vote, :cause_id => cause.id
    
    #changes persisted:
    assert_not_nil Vote.find_by_cause_id_and_user_id cause.id, user.id
    
    #response ok:
    vote_result = JSON.parse(@request.body)
    assert_equal true, vote_result['success']
    assert_equal MESSAGE_OK, vote_result['message']
  end
  
  
  test "votes should persist in database if everything is ok (no ajax) " do
    user = create_user
    user.confirm!
    sign_in user
    cause = Cause.make
    votes_count = Vote.length
    
    post :vote, {'cause_id' => cause.id.to_s} 
    
    #vote persisted:
    assert_equal votes_count+1,Vote.length
    
    #response ok
    assert_response :success
    
  end
end
