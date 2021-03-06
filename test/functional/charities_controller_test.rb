require 'test_helper'

class CharitiesControllerTest < ActionController::TestCase

  #DETAILS
  test "should get details if active" do
    charity = Charity.make :short_url => "foobar",:status => :active

    get :details, :url => "foobar"

    assert_not_nil assigns(:charity)
    assert_equal assigns(:charity), charity
    assert_response :success
  end

  #DETAILS
  test "should get details if inactive and admin logged" do
    user = create_admin_and_sign_in
    charity = Charity.make :short_url => "foobar",:status => :inactive

    get :details, :url => "foobar"

    assert_not_nil assigns(:charity)
    assert_equal assigns(:charity), charity
    assert_response :success
  end

  #DETAILS
  test "should get details if inactive and inactive charity is logged" do

    charity = create_charity_and_sign_in
    charity.short_url = "foobar"
    charity.status = :inactive
    charity.save!

    get :details, :url => "foobar"

    assert_not_nil assigns(:charity)
    assert_equal assigns(:charity), charity
    assert_response :success
  end


  #DETAILS
  test "shouldnt get details if inactive and not admin or charity owner" do
    user = create_charity_and_sign_in
    charity = Charity.make :short_url => "foobar",:status => :inactive, :charity_name => 'charity name'

    get :details, :url => "foobar"

    assert_not_nil assigns(:charity)
    assert_equal assigns(:charity), charity
    assert_equal assigns(:kind), 'charity'
    assert_equal assigns(:name), 'charity name'

    assert_select '#page_inactive', _('The') + ' charity charity name ' + _('is inactive.')
    assert_select '#doubts_contact', _('For any doubts, please contact') + ' info@bivo.org'

    assert_response :success
  end

  #DETAILS
 test "shouldnt get details if inactive and not admin or charity, personal user logged in" do
    user = create_and_sign_in
    charity = Charity.make :short_url => "foobar",:status => :inactive, :charity_name => 'charity name'

    get :details, :url => "foobar"

    assert_not_nil assigns(:charity)
    assert_equal assigns(:charity), charity
    assert_equal assigns(:kind), 'charity'
    assert_equal assigns(:name), 'charity name'

    assert_select '#page_inactive', _('The') + ' charity charity name ' + _('is inactive.')
    assert_select '#doubts_contact', _('For any doubts, please contact') + ' info@bivo.org'

    assert_response :success
  end

  #LIST
  test "should get active charities in list" do
    Charity.make_many 10

    get :index

    assert_charities_unsorted Charity.all
  end

  test "should not get inactive charities on the list" do
    Charity.make_many 5
    Charity.make :status => :inactive

    get :index

    assert_charities_unsorted Charity.where('users.status != ?', :inactive)
  end

  test "should not get inactive charities on the list despite beeing admin" do
    user = create_admin_and_sign_in
    Charity.make_many 5
    Charity.make :status => :inactive

    get :index

    assert_charities_unsorted Charity.where('users.status != ?', :inactive)
  end

  test "should not get inactive charities on the list beeing the inactive charity" do
    Charity.make_many 5
    Charity.make :status => :inactive
    user = create_charity_and_sign_in
    user.status = :inactive
    user.save!

    get :index

    assert_charities_unsorted Charity.where('users.status != ?', :inactive)
  end

  test "should get charities list with categories" do
    categories = CharityCategory.make_many 3
    charities = categories.map{|category| Charity.make_many(2, :charity_category => category)}.flatten

    get :index

    assert_charities_unsorted charities

    assert_not_nil assigns(:categories)
    assert_equal 4, assigns(:categories).size
  end

  test "should get charities list first page" do
    charities = ('A'..'Z').map{|name| Charity.make(:charity_name => name)}

    get :index

    assert_charities charities.first(10)
  end

  test "should get charities list second page different size" do
    charities = ('A'..'Z').map {|name| Charity.make(:charity_name => name)}

    get :index, :page => 2, :per_page => 20

    assert_charities charities[20...40]
  end

  test "should get charities list filter by category" do
    category = CharityCategory.make
    other_category = CharityCategory.make
    charities = Charity.make_many 3, :charity_category => category
    Charity.make_many 10, :charity_category => other_category

    get :index, :category => category.id

    assert_charities_unsorted charities
  end

  test "should get charities list filter by country" do
    country = Country.make
    other_country = Country.make
    charities = Charity.make_many 3, :country => country
    Charity.make_many 10, :country => other_country

    get :index, :region => country.id

    assert_charities_unsorted charities
  end

  test "should get charities list filter by keyword" do
    charities = [Charity.make(:charity_name => 'keyword'), Charity.make(:description => 'keyword')]
    Charity.make_many 10

    get :index, :name => 'keyword'

    assert_charities_unsorted charities
  end

  test "should get charities list sorted alphabetically" do
    charities = ['C','B','A'].map {|name| Charity.make :charity_name => name}

    get :index, :sorting => :alphabetical

    assert_charities charities.reverse
  end

  test "should get charities list sorted geographically" do
    charities = ['C','B','A'].map {|name| Charity.make :country => Country.make(:name => name)}

    get :index, :sorting => :geographical

    assert_charities charities.reverse
  end

  test "should get charities list sorted by rating" do
    charities = (1..5).map {|rating| Charity.make :rating => rating}

    get :index, :sorting => :rating

    assert_charities charities.reverse
  end

  test "should get charities list sorted by funds raised" do
    charities = (1..5).map do |funds|
      c = Charity.make
      Cause.make :funds_raised => funds, :status => :raising_funds, :charity => c
      Cause.make :funds_raised => funds * 2, :status => :completed, :charity => c
      c
    end

    get :index, :sorting => :funds_raised

    assert_charities charities.reverse
  end

  test "should get charities list sorted by popularity" do
    charities = (1..5).map do |votes|
      c = Charity.make
      Cause.make_with_votes :votes_count => votes,   :charity => c
      Cause.make_with_votes :votes_count => votes*2, :charity => c
      c
    end

    get :index, :sorting => :votes

    assert_charities charities.reverse
  end

  #SHOW
  test "show charity" do
    charity = Charity.make
    get :show, :id => charity.id
    assert_response :ok
  end

  #FOLLOW
  test "can follow" do
    user = create_and_sign_in
    charity = Charity.make
    xhr :post, :follow, :id => charity.id

    assert_equal CharityFollow.count,1
    assert_response :ok
  end

  #FOLLOW
  test "shouldnt follow" do
    user = create_and_sign_in
    charity = Charity.make
    xhr :post, :follow, :id => charity.id
    assert_equal CharityFollow.count,1
    assert_response :ok
    xhr :post, :follow, :id => charity.id
    assert_equal CharityFollow.count,1
    assert_response :ok
  end

  #FOLLOW
  test "shouldnt follow if inactive and not admin or self" do
    user = create_and_sign_in
    charity = Charity.make(:status => :inactive)
    xhr :post, :follow, :id => charity.id
    assert_equal 0,CharityFollow.count
    assert_response :ok
  end

  #FOLLOW
  test "shouldnt follow if not logged" do
    charity = Charity.make
    xhr :post, :follow, :id => charity.id
    assert_equal 0,CharityFollow.count
    assert_response :unauthorized
  end

  #FOLLOW
  test "should follow if inactive admin" do
    user = create_admin_and_sign_in
    charity = Charity.make(:status => :inactive)
    xhr :post, :follow, :id => charity.id
    assert_equal 1,CharityFollow.count
    assert_response :ok
  end

  #FOLLOW
  test "should follow if inactive (self)" do
    charity = create_charity_and_sign_in :status => :inactive
    xhr :post, :follow, :id => charity.id
    assert_equal 1,CharityFollow.count
    assert_response :ok
  end

  #UNFOLLOW
  test "can unfollow" do
    user = create_and_sign_in
    charity = Charity.make
    post :follow, :id => charity.id
    assert_equal CharityFollow.count,1
    assert_response :found
    xhr :post, :unfollow, :id => charity.id
    assert_equal CharityFollow.count,0
    assert_response :ok
  end

  #UNFOLLOW
  test "shouldnt unfollow" do
    user = create_and_sign_in
    charity = Charity.make
    xhr :post, :unfollow, :id => charity.id
    assert_equal CharityFollow.count,0
    assert_response :method_not_allowed
  end

  #UNFOLLOW
  test "shouldnt unfollow if not logged" do
    charity = Charity.make
    xhr :post, :unfollow, :id => charity.id

    assert_response :unauthorized
  end

  #ACTIVATE
  test "should activate" do
    user = create_admin_and_sign_in
    id = Charity.make(:status=>:inactive).id
    post :activate, :id => id
    assert_response :found
    assert_equal :active,Charity.find(id).status
  end

  #ACTIVATE
  test "should not activate" do
    user = create_charity_and_sign_in
    id = Charity.make(:status=>:inactive).id
    post :activate, :id => id
    assert_response :forbidden
    assert_equal :inactive,Charity.find(id).status
  end


  #DEACTIVATE
  test "should deactivate and children" do
    user = create_admin_and_sign_in
    id = Charity.make(:status=>:active).id
    cause = Cause.make :status =>:active,:charity_id => id
    post :deactivate, :id => id
    assert_response :found
    assert_equal :inactive,Charity.find(id).status
    assert_equal :inactive,cause.reload.status
  end

  #DEACTIVATE
  [:raising_funds, :completed, :paid].each do |status|
    test "should not deactivate because of children status(#{status})" do
      user = create_admin_and_sign_in
      id = Charity.make(:status=>:active).id
      cause = Cause.make :status => status, :charity_id => id
      post :deactivate, :id => id

      assert_response :redirect
      assert_match /Error deactivating charity/, flash[:notice]
      assert_equal :active, Charity.find(id).status
      assert_equal status, cause.reload.status
    end
  end

  #DEACTIVATE
  test "should not deactivate self" do
    user = create_charity_and_sign_in
    id = Charity.make(:status=>:active).id
    cause = Cause.make :status =>:active,:charity_id => id
    post :deactivate, :id => id
    assert_response :forbidden
    assert_equal :active,Charity.find(id).status
    assert_equal :active,Cause.find(cause.id).status
  end

  #CHECK_URL
  test "should check url and return ok" do
    get :check_url, :url=>"aurl"
    assert_equal 'available',@response.body.to_s
  end

  #CHECK_URL
  test "should validate url" do
    get :check_url, :url=>"url.bad"
    assert_equal 'invalid',@response.body.to_s
  end
  
  #CHECK_URL
  test "should reject url" do
    url = Charity.make.short_url
    get :check_url, :url=>url
    assert_equal 'not_available',@response.body.to_s
  end
  
  test "should get comments to approve" do
    charity = create_charity_and_sign_in
    cause = Cause.make :charity => charity
    
    create_comment charity, "comment in charity"
    create_comment cause, "comment in cause"
    
    get :manage_comments, :id => charity.id
    
    assert_response :success
  end
  
  private

  def assert_charities_unsorted(causes_or_ids)
    assert_charities(causes_or_ids, false)
  end

  def assert_charities(causes_or_ids, check_sort=true, field=nil)
    ids = causes_or_ids.map {|c| c.respond_to?(:id) ? c.id : c}
    assert_not_nil assigns(:charities), "Must assign charities object"
    assert_equal ids.size, assigns(:charities).size, "Incorrect number of charities returned"
    assert_equal_unordered ids, assigns(:charities).map(&:id), "Ids do not match"
    assert_equal ids, assigns(:charities).map(&:id), "Ids order does not match" if check_sort
  end

  def create_comment(entity, text)
    comment = Comment.build_from(entity, PersonalUser.make.id, text)
    comment.save!
  end
end

