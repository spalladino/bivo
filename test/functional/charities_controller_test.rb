require 'test_helper'

class CharitiesControllerTest < ActionController::TestCase

#LIST
  test "should get charities list" do
    Charity.make_many 10

    get :index

    assert_charities_unsorted Charity.all
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
    ('A'..'Z').map {|name| Charity.make(:charity_name => name)}

    get :index

    assert_charities Charity.where('charity_name < ?', 'K')
  end

  test "should get charities list second page different size" do
    ('A'..'Z').map {|name| Charity.make(:charity_name => name)}

    get :index, :page => 2, :per_page => 20

    assert_charities Charity.where('charity_name > ?', 'T')
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


  #DETAILS
  test "should get details" do
    charity = Charity.make :short_url => "foobar"

    get :details, :url => "foobar"

    assert_not_nil assigns(:charity)
    assert_equal assigns(:charity), charity
    assert_response :success
  end

  #NEW
  test "should go to new charity" do
    #TODO completar
    assert_response :ok
  end

  #NEW
  test "shouldnt go to new charity" do
    #TODO completar
    assert_response :ok
  end

  #EDIT
  test "should go to edit charity" do
    #TODO completar
    assert_response :ok
  end

  #EDIT
  test "shouldnt go to edit charity" do
    #TODO completar
    assert_response :ok
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

  #CREATE
  test "should create" do
    #TODO completar
    assert_response :ok
  end

  #CREATE
  test "shouldnt create" do
    #TODO completar
    assert_response :ok
  end

  #UPDATE
  test "shoul update" do
    #TODO completar
    assert_response :ok
  end

  #UPDATE
  test "shouldnt update" do
    #TODO completar
    assert_response :ok
  end

  #DESTROY
  test "shouldnt destroy" do
    #TODO completar
    assert_response :ok
  end

  #DESTROY
  test "should make logical destroy" do
    #TODO completar
    assert_response :ok
  end

  #DESTROY
  test "should make complete destroy" do
    #TODO completar
    assert_response :ok
  end


  #CHECK_URL
  test "should check url and return ok" do
    #TODO completar
    assert_response :ok
  end

  #CHECK_URL
  test "should reject url" do
    #TODO completar
    assert_response :ok
  end

  #ACTIVATE
  test "should activate" do
    #TODO: finish this
    #user = create_admin_and_sign_in
    #charity = Charity.make :status=>:inactive
    #post :activate, :id => charity.id
    #assert_response :found
    #assert_equal :active,charity.reload.status
  end

  #ACTIVATE
  test "should not activate" do
    user = create_charity_and_sign_in
    charity = Charity.make :status=>:inactive
    post :activate, :id => charity.id
    assert_response :forbidden
    assert_equal :inactive,charity.reload.status
  end


  #DEACTIVATE
  test "should deactivate and children" do
    #TODO: finish this
    #user = create_admin_and_sign_in
    #charity = Charity.make :status=>:active
    #post :deactivate, :id => charity.id
    #assert_response :found
    #assert_equal :inactive,charity.reload.status
  end

  #DEACTIVATE
  test "should not deactivate" do
    user = create_charity_and_sign_in
    charity = Charity.make :status=>:active
    post :deactivate, :id => charity.id
    assert_response :forbidden
    assert_equal :active,charity.reload.status
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

end

