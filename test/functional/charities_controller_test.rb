require 'test_helper'

class CharitiesControllerTest < ActionController::TestCase

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

    assert_charities Charity.all[0...10]
  end
  
  test "should get charities list second page different size" do
    ('A'..'Z').map {|name| Charity.make(:charity_name => name)}
    
    get :index, :page => 2, :per_page => 20

    assert_charities Charity.all[20...40]
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
