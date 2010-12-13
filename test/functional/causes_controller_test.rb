require 'test_helper'

class CausesControllerTest < ActionController::TestCase

  #DETAILS
  test "should get details if active cause" do
    cause = Cause.make :url => "foobar",:status => :active

    get :details, :url => "foobar"

    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_response :success
  end

  #DETAILS
  test "shouldnt get details of inactive cause if not owner nor admin" do
    cause = Cause.make :url => "foobar",:status => :inactive, :name => 'cause name'

    get :details, :url => "foobar"

    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_equal assigns(:kind), 'cause'
    assert_equal assigns(:name), 'cause name'
    assert_response :success
  end

  #DETAILS
  test "should get details if inactive and owner" do
    user = create_charity_and_sign_in
    cause = Cause.make :url => "foobar",:status => :inactive, :charity_id => user.id

    get :details, :url => "foobar"

    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_response :success
  end

 #DETAILS
  test "should get details if inactive and admin" do
    user = create_admin_and_sign_in
    cause = Cause.make :url => "foobar",:status => :inactive

    get :details, :url => "foobar"

    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_response :success
  end

  #NEW
  test "can go to new cause" do
    user = create_charity_and_sign_in
    get :new
    assert_response :success
  end

  #EDIT
  test "can go to edit cause" do
    user = create_charity_and_sign_in
    cause = Cause.make :charity_id => user.id
    get :edit, :id => cause.id
    assert_not_nil assigns(:cause)
    assert_equal assigns(:cause), cause
    assert_response :ok
  end

 #EDIT
  test "cant go to edit cause becouse is another charity's cause'" do
    user = create_charity_and_sign_in
    cause = Cause.make :charity_id => Charity.make.id
    get :edit, :id => cause.id

    assert_response :forbidden
  end

   #EDIT
  test "cant go to edit cause because is completed" do
    user = create_charity_and_sign_in
    cause = Cause.make :charity_id => user.id, :status=>:completed
    get :edit, :id => cause.id

    assert_response :forbidden
  end

  #VOTE-already voted
  test "should fail on vote if already voted with ajax and response is ok" do
    user = create_and_sign_in
    cause = Cause.make :status => :active
    existing_vote = Vote.make :user => user,:cause_id => cause.id
    votes_count = Vote.count

    xhr :post, :vote, :id => existing_vote.cause_id

    #no votes added:
    assert_equal votes_count, Vote.count

    #response ok:
    assert_response :ok
  end


  #VOTE-not authenticated
  test "should fail on vote if not authenticated user and error is correct no ajax" do
    cause = Cause.make
    cause_counter = cause.votes.count

    post :vote, :id => cause.id
    cause.reload

    #no votes added:
    assert_equal cause_counter,cause.votes.count

    #error is correct:
    assert_response :found
  end

  #VOTE-status
  test "should fail on vote if cause status doesnt support voting with ajax" do
    user = create_and_sign_in
    cause = Cause.make(:status => "raising_funds")

    xhr :post, :vote, :id => cause.id

    #response correct:
    assert_response :ok

    #the information doesnt persist:
    assert_nil Vote.find_by_cause_id_and_user_id cause.id, user.id
  end


  #VOTE-ok-ajax
  test "votes should persist in database with ajax" do
    user = create_and_sign_in
    cause = Cause.make
    cause.save

    xhr :post, :vote, :id => cause.id

    #changes persisted:
    assert_not_nil Vote.find_by_cause_id_and_user_id cause.id, user.id

    #response ok:
    assert_response :ok
  end

  #VOTE-ok-no ajax
  test "votes should persist in database no ajax" do
    user = create_and_sign_in
    cause = Cause.make :status => :active
    votes_count = Vote.count

    post :vote, :id => cause.id

    #vote persisted:
    assert_equal votes_count+1, Vote.count

    #response ok
    assert_response :found
  end


  #SHOW
  test "show" do
    cause = Cause.make
    get :show, :id => cause.id
    assert_response :ok
  end

  #FOLLOW
  test "can follow" do
    user = create_and_sign_in
    cause = Cause.make
    xhr :post, :follow, :id => cause.id

    assert_equal Follow.count,1
    assert_response :ok
  end

  #FOLLOW
  test "shouldnt follow" do
    user = create_and_sign_in
    cause = Cause.make
    xhr :post, :follow, :id => cause.id
    assert_equal Follow.count,1
    assert_response :ok
    xhr :post, :follow, :id => cause.id
    assert_equal Follow.count,1
    assert_response :ok
  end

  #UNFOLLOW
  test "can unfollow" do
    user = create_and_sign_in
    cause = Cause.make
    post :follow, :id => cause.id
    assert_equal Follow.count,1
    assert_response :found
    xhr :post, :unfollow, :id => cause.id
    assert_equal Follow.count,0
    assert_response :ok
  end

  #UNFOLLOW
  test "shouldnt unfollow" do
    user = create_and_sign_in
    cause = Cause.make
    xhr :post, :unfollow, :id => cause.id
    assert_equal Follow.count,0
    assert_response :method_not_allowed
  end

  #CREATE
  test "should create cause" do
    user = create_charity_and_sign_in
    post :create,
    :cause =>
      {
        :name => 'Hi',
        :description=>"ss",
        :city => "cba",
        :status =>:active,
        :charity_id =>user.id,
        :country_id =>Country.make.id,
        :cause_category_id=>CauseCategory.make.id,
        :url=> "url",
        :funds_needed=>100,
        :funds_raised=>0
      }
    assert_equal 1,Cause.count
    assert_redirected_to :action => :details, :url => "url"
  end

  #CREATE
  test "should not create causes from inactive charity" do
    user = create_charity_and_sign_in :status => :inactive

    post :create,
    :cause =>
      {
        :name => 'Hi',
        :description=>"ss",
        :city => "cba",
        :status =>:active,
        :charity_id =>user.id,
        :country_id =>Country.make.id,
        :cause_category_id=>CauseCategory.make.id,
        :url=> "url",
        :funds_needed=>100,
        :funds_raised=>0
      }
    assert_equal 0,Cause.count
    assert_template 'new'
  end

  #CREATE
  test "shouldnt create cause" do
    user = create_charity_and_sign_in
    post :create,
      :cause =>
      {
        :name => 'Hi',
        :city => "cba",
        :status =>:active,
        :charity_id =>user.id,
        :country_id =>Country.make.id,
        :cause_category_id=>CauseCategory.make.id,
        :url=> "url",
        :funds_needed=>100,
        :funds_raised=>0
      }
    assert_equal 0,Cause.count
    assert_response :ok
  end

  #UPDATE
  test "should update" do
    user = create_charity_and_sign_in
    cause_old = Cause.make :charity_id => user.id
    post :update,
      :id=>cause_old.id,
      :cause =>
      {
        :name => 'Hi',
        :description=>"ss",
        :city => "cba",
        :status =>:active,
        :charity_id =>user.id,
        :country_id =>Country.make.id,
        :cause_category_id=>CauseCategory.make.id,
        :url=> "url",
        :funds_needed=>100,
        :funds_raised=>0
      }
    cause = Cause.find(cause_old.id)
    assert_equal cause_old.id,cause.id
    assert_not_equal cause_old.name,cause.name
    assert_equal "Hi",cause.name
    assert_response :found
  end

  test "shouldnt change to raising funds if there is one in that state of the same category" do
    user = create_charity_and_sign_in
    cause_category = CauseCategory.make
    raising_funds_cause = Cause.make :charity_id => user.id, :status => :raising_funds,
      :cause_category_id => cause_category.id
    active_cause = Cause.make :charity_id => user.id, :status => :active,
      :cause_category_id => cause_category.id

    post :update,
      :id => active_cause.id,
      :cause =>
      {
        :name => 'Hi',
        :description =>"ss",
        :city => "cba",
        :status => :raising_funds,
        :charity_id => user.id,
        :country_id => Country.make.id,
        :cause_category_id => cause_category.id,
        :url => "url",
        :funds_needed => 100,
        :funds_raised => 0
      }

    cause = Cause.find(active_cause.id)

    assert_not_equal active_cause.status, :raising_funds
    assert_response :found
  end

  test "should change to raising funds if there isnt any in that state of the same category" do
    user = create_charity_and_sign_in
    cause_category = CauseCategory.make
    active_cause = Cause.make :charity_id => user.id, :status => :active,
      :cause_category_id => cause_category.id

    post :update,
      :id => active_cause.id,
      :cause =>
      {
        :name => 'Hi',
        :description =>"ss",
        :city => "cba",
        :status => :raising_funds,
        :charity_id => user.id,
        :country_id => Country.make.id,
        :cause_category_id => cause_category.id,
        :url => "url",
        :funds_needed => 100,
        :funds_raised => 0
      }

    cause = Cause.find(active_cause.id)

    assert_not_equal active_cause.status, :raising_funds
    assert_response :found
  end

  #UPDATE
  test "shouldnt update" do
    user = create_charity_and_sign_in
    cause_old = Cause.make :charity_id => user.id
    post :update,
      :id=>cause_old.id,
      :cause =>
      {
        :name => 'Hi',
        :description => nil,
        :city => "cba",
        :status =>:active,
        :charity_id =>user.id,
        :country_id =>Country.make.id,
        :cause_category_id=>CauseCategory.make.id,
        :url=> "url",
        :funds_needed=>100,
        :funds_raised=>0
      }
    cause = Cause.find(cause_old.id)
    assert_equal cause_old,cause
    assert_not_equal "Hi",cause.name
    assert_response :found
  end

  #DESTROY
  test "shouldnt destroy" do
#TODO [nombre del test]
    assert_response :ok
  end

  #DESTROY
  test "should make logical destroy" do
#TODO [nombre del test]
    assert_response :ok
  end

  #DESTROY
  test "should make complete destroy" do
#TODO [nombre del test]
    assert_response :ok
  end


  #CHECK_URL
  test "should check url and return ok" do
    user = create_and_sign_in
    get :check_url, :url=>"url"
    assert_equal 'available',@response.body.to_s
  end

  #CHECK_URL
  test "should reject url" do
    user = create_and_sign_in
    url = Cause.make.url
    get :check_url, :url=>url
    assert_equal 'not_available',@response.body.to_s
  end

  #ACTIVATE
  test "should activate" do
    user = create_admin_and_sign_in
    cause = Cause.make :status=>:inactive
    post :activate, :id => cause.id
    assert_response :found
    assert_equal :active,cause.reload.status
  end

  #ACTIVATE
  test 'shouldnt activate causes whith inactive owner' do
    user = create_admin_and_sign_in
    charity = Charity.make
    cause = Cause.make(:status=>:inactive, :charity => charity)
    charity.status = :inactive
    charity.save!
    
    post :activate, :id => cause.id
    assert_response :found
    assert_equal :inactive,cause.reload.status
  end

  #ACTIVATE
  test "should not activate if not admin" do
    user = create_charity_and_sign_in
    cause = Cause.make :status=>:inactive
    post :activate, :id => cause.id
    assert_response :forbidden
    assert_equal :inactive,cause.reload.status
  end


  #DEACTIVATE
  test "should deactivate" do
    user = create_admin_and_sign_in
    cause = Cause.make :status=>:active
    post :deactivate, :id => cause.id
    assert_response :found
    assert_equal :inactive,cause.reload.status
  end

  #DEACTIVATE
  test "should not deactivate" do
    user = create_charity_and_sign_in
    cause = Cause.make :status=>:active
    post :deactivate, :id => cause.id
    assert_response :forbidden
    assert_equal :active,cause.reload.status
  end

  #MARK PAID
  test "should mark as paid" do
    user = create_admin_and_sign_in
    cause = Cause.make :status=>:completed
    post :mark_paid, :id => cause.id
    assert_response :found
    assert_equal :paid,cause.reload.status
  end

  #MARK PAID
  test "shouldnt mark as paid" do
    user = create_and_sign_in
    cause = Cause.make :status=>:completed
    post :mark_paid, :id => cause.id
    assert_response :forbidden
    assert_equal :completed,cause.reload.status
  end

  #MARK UNPAID
  test "should mark as unpaid" do
    user = create_admin_and_sign_in
    cause = Cause.make :status=>:paid
    post :mark_unpaid, :id => cause.id
    assert_response :found
    assert_equal :completed,cause.reload.status
  end

  #MARK UNPAID
  test "shouldnt mark as unpaid" do
    user = create_charity_and_sign_in
    cause = Cause.make :status=>:paid
    post :mark_unpaid, :id => cause.id
    assert_response :forbidden
    assert_equal :paid,cause.reload.status
  end

  test "should allow edition of name, short_url nor funds_needed if inactive as admin" do
    create_admin_and_sign_in
    cause = Cause.make :status => :inactive
    
    get :edit, :id => cause.id

    assert_edit_sensitve_data
    assert_can_update_name cause
  end
  
  [:active, :raising_funds, :completed, :paid].each do |status|
    test "should not allow edition of name, short_url nor funds_needed if #{status} as admin" do
      create_admin_and_sign_in
      cause = Cause.make :status => status
      
      get :edit, :id => cause.id

      assert_readonly_sensitve_data
      assert_cant_update_name cause
    end
  end
  
  test "should allow edition of name, short_url nor funds_needed if inactive as charity" do
    charity = create_charity_and_sign_in
    cause = Cause.make :charity => charity, :status => :inactive
    
    get :edit, :id => cause.id

    assert_edit_sensitve_data
    assert_can_update_name cause
  end
  
  [:active, :raising_funds].each do |status|
    test "should not allow edition of name, short_url nor funds_needed if #{status} as charity" do
      create_admin_and_sign_in
      cause = Cause.make :status => status
      
      get :edit, :id => cause.id

      assert_readonly_sensitve_data
      assert_cant_update_name cause
    end
  end
  
  [:completed, :paid].each do |status|
    test "should not allow edition of name, short_url nor funds_needed if #{status} as charity" do
       user = create_charity_and_sign_in
       cause = Cause.make :charity_id => user.id, :status=> status
       get :edit, :id => cause.id

       assert_response :forbidden
       assert_cant_update_name cause
    end
  end
  
  private
  
  def assert_edit_sensitve_data
    assert_response :success

    assert_equal 1, css_select('#cause_name').count
    assert_equal 1, css_select('#short_url').count
    assert_equal 1, css_select('#cause_funds_needed').count
    assert_equal 1, css_select('textarea').count # description field
  end
  
  def assert_readonly_sensitve_data
    assert_response :success

    assert_equal 0, css_select('#cause_name').count
    assert_equal 0, css_select('#short_Url').count
    assert_equal 0, css_select('#cause_funds_needed').count
    assert_equal 1, css_select('textarea').count # description field
  end
  
  def assert_can_update_name(cause)
    post :update,
      :id => cause.id,
      :cause =>
      {
        :name => 'changed',
        :description=> cause.description,
        :city => cause.city,
        :status => cause.status,
        :charity_id => cause.charity_id,
        :country_id => cause.country_id,
        :cause_category_id=> cause.cause_category_id,
        :url=> cause.url,
        :funds_needed=> cause.funds_needed,
        :funds_raised=> cause.funds_raised
      }   
      
    cause.reload
    assert_equal 'changed', cause.name
  end
  
  def assert_cant_update_name(cause)
    old_name = cause.name
    
    post :update,
      :id => cause.id,
      :cause =>
      {
        :name => 'changed',
        :description=> cause.description,
        :city => cause.city,
        :status => cause.status,
        :charity_id => cause.charity_id,
        :country_id => cause.country_id,
        :cause_category_id=> cause.cause_category_id,
        :url=> cause.url,
        :funds_needed=> cause.funds_needed,
        :funds_raised=> cause.funds_raised
      }   
      
    cause.reload
    assert_equal old_name, cause.name
  end
end

