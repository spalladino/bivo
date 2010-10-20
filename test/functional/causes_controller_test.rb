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

  test "should get causes list voting status first page sorted by popularity" do
    create_incremental_voted_causes
    causes_ids = Cause.all.map(&:id).sort.reverse

    get :index, :sorting => :votes

    assert_not_nil assigns(:causes)
    assert_equal 5, assigns(:causes).size
    assert_equal causes_ids[0...5], assigns(:causes).map(&:id)
  end

  test "should get causes list voting status different page and count sorted by popularity" do
    create_incremental_voted_causes
    causes_ids = Cause.all.map(&:id).sort.reverse

    get :index, :page => 2, :per_page => 10, :sorting => :votes

    assert_not_nil assigns(:causes)
    assert_equal 10, assigns(:causes).size
    assert_equal causes_ids[10...20], assigns(:causes).map(&:id)
  end
  
  test "should get causes list raising funds filtered by name" do
    causes_ids = [ 
      Cause.make(:name => 'keyword', :status => :raising_funds).id, 
      Cause.make(:description => 'keyword', :status => :raising_funds).id 
    ] 
    
    Cause.make_many 20, :status => :raising_funds
    Cause.make :description => 'keyword', :status => :active
    
    get :index, :name => 'keyword', :status => :raising_funds

    assert_not_nil assigns(:causes)
    assert_equal 2, assigns(:causes).size
    assert_equal_unordered causes_ids, assigns(:causes).map(&:id)
  end
  
  test "should get causes list completed status filtered by category" do
    CauseCategory.make_many 2
    
    causes = Cause.make_many 3, :status => :completed, :cause_category => CauseCategory.first
    
    Cause.make_many 3, :status => :raising_funds, :cause_category => CauseCategory.first 
    Cause.make_many 3, :status => :completed, :cause_category => CauseCategory.last
    
    get :index, :status => :completed, :category => CauseCategory.first.id

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_equal_unordered causes.map(&:id), assigns(:causes).map(&:id)
  end

  test "should get causes list sorted geographically" do
    countries = [ Country.make(:name => 'Argentina'),
                  Country.make(:name => 'Brazil'),
                  Country.make(:name => 'Canada')]
    
    Cause.make :status => :active, :country => countries[2]
    Cause.make :status => :active, :country => countries[1]
    
    Cause.make :status => :active, :country => countries[0], :city => "Cordoba"
    Cause.make :status => :active, :country => countries[0], :city => "Buenos Aires"
    Cause.make :status => :active, :country => countries[0], :city => "Arroyito"
    
    get :index, :status => :active, :sorting => :geographical

    assert_not_nil assigns(:causes)
    assert_equal 5, assigns(:causes).size
    assert_causes_returned_order_reverse 
  end
  
  test "should get causes list sorted alphabetically" do
    Cause.make :name => "C Cause"
    Cause.make :name => "B Cause"
    Cause.make :name => "A Cause"
    
    get :index, :sorting => :alphabetical

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end

  test "should get causes list sorted by charity rating" do
    Cause.make :charity => (Charity.make :rating => 3)
    Cause.make :charity => (Charity.make :rating => 4)    
    Cause.make :charity => (Charity.make :rating => 5)
    
    get :index, :sorting => :rating

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end
  
  test "should get causes list sorted by completion percentage" do
    Cause.make :status => :raising_funds, :funds_needed => 1000, :funds_raised => 700
    Cause.make :status => :raising_funds, :funds_needed => 100, :funds_raised => 80
    Cause.make :status => :raising_funds, :funds_needed => 10000, :funds_raised => 9000
    
    get :index, :sorting => :completion, :status => :raising_funds

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end
  
  test "should get causes list sorted by funds needed" do
    Cause.make :status => :raising_funds, :funds_needed => 10
    Cause.make :status => :raising_funds, :funds_needed => 50
    Cause.make :status => :raising_funds, :funds_needed => 100
    
    get :index, :sorting => :funds_needed, :status => :raising_funds

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end
  
  test "should get causes list sorted by funds raised" do
    Cause.make :status => :raising_funds, :funds_raised => 10
    Cause.make :status => :raising_funds, :funds_raised => 50
    Cause.make :status => :raising_funds, :funds_raised => 100
    
    get :index, :sorting => :funds_raised, :status => :raising_funds

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end
  
  test "should get causes list limiting item count" do
    Cause.make_many 60, :status => :active
    
    get :index, :per_page => 100, :status => :active

    assert_not_nil assigns(:causes)
    assert_equal 50, assigns(:causes).size
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
    assert_equal flash[:notice], "The user should be authenticated"
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
    assert_response :success

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
  
  private
  
  def assert_causes_returned_order_reverse(causes=assigns(:causes))
    assert_equal Cause.all.map(&:id).sort.reverse, causes.map(&:id)
  end
  
end

