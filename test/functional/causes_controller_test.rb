require 'test_helper'

class CausesControllerTest < ActionController::TestCase

  MESSAGE_OK = "Ok"
  MESSAGE_FAIL_ALREADY_VOTE = "Voted"
  MESSAGE_FAIL_STATUS_PROBLEM = "The cause status doesnt allow voting"
  MESSAGE_FAIL_AUTH_PROBLEM = "The user should be authenticated"

  test "should get details" do
    cause = Cause.make :url => "foobar"

    get :details, :url => "foobar"

    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_response :success
  end

  test "should get voting causes list first page sorted by popularity" do
    # Create causes with votes
    (1..20).each { |i| Cause.make_with_votes :votes_count => i, :status => :active }

    # Fetch the voted ones sorted by vote count
    causes_with_votes_ids = Cause.all.map(&:id).sort.reverse

    get :index

    assert_not_nil assigns(:causes)
    assert_equal 5, assigns(:causes).size
    assert_equal causes_with_votes_ids[0...5], assigns(:causes).map(&:id)
  end

  test "should get voting causes list first different page and count sorted by popularity" do
    # Create 60 causes with votes
    (1..20).each { |i| Cause.make_with_votes :votes_count => i, :status => :active }

    # Fetch the voted ones sorted by vote count
    causes_with_votes_ids = Cause.all.map(&:id).sort.reverse

    get :index, :page => 2, :per_page => 5

    assert_not_nil assigns(:causes)
    assert_equal 5, assigns(:causes).size
    assert_equal causes_with_votes_ids[5...10], assigns(:causes).map(&:id)
  end


  test "should fail on vote if already voted with ajax and response is correct" do
    user = create_and_sign_in

    cause = Cause.make :status => :active

    existing_vote = Vote.make :user => user,:cause_id => cause.id



    votes_count = Vote.count

    xhr :post, :vote, :id => existing_vote.cause_id

    #no votes added:
    assert_equal votes_count, Vote.count

    #response ok:
    vote_result = JSON.parse(@request.body)
    assert_equal false, vote_result['success']
    assert_equal MESSAGE_FAIL_ALREADY_VOTE, vote_result['message']
  end


  test "should fail on vote if not authenticated user and error is correct no ajax" do
    cause = Cause.make
    cause_counter = cause.votes.count

    post :vote, :id => cause.id
    cause.reload

    #no votes added:
    assert_equal cause_counter,cause.votes.count

    #error is correct:
    assert_response :error
  end


  test "should fail on vote if cause status doesnt support voting with ajax" do
    user = create_and_sign_in
    cause = Cause.make(:status => "raising_funds")

    xhr :post, :vote, :id => cause.id

    #response correct:
    vote_result = JSON.parse(@request.body)
    assert_equal false, vote_result['success']
    assert_equal MESSAGE_FAIL_STATUS_PROBLEM, vote_result['message']

    #the information doesnt persist:
    assert_nil Vote.find_by_cause_id_and_user_id cause.id, user.id
  end


  test "votes should persist in database with ajax" do
    user = create_and_sign_in
    cause = Cause.make
    cause.save

    xhr :post, :vote, :id => cause.id

    #changes persisted:
    assert_not_nil Vote.find_by_cause_id_and_user_id cause.id, user.id

    #response ok:
    vote_result = JSON.parse(@request.body)
    assert_equal true, vote_result['success']
    assert_equal MESSAGE_OK, vote_result['message']
  end


  test "votes should persist in database no ajax" do
    user = create_and_sign_in
    cause = Cause.make :status => :active
    votes_count = Vote.count

    post :vote, :id => cause.id

    #vote persisted:
    assert_equal votes_count+1, Vote.count

    #response ok
    assert_response 302

  end

  test "can go to new cause" do
    user = create_and_sign_in
    get :new
    assert_response :success
  end

  test "can go to edit cause" do
    user = create_and_sign_in

    cause = Cause.make
    get :edit, :id => cause.id
    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_response :success
  end
end

