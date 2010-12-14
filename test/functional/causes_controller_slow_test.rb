require 'test_helper'

class CausesControllerSlowTest < ActionController::TestCase

  def self.controller_class; CausesController; end
  
  #LIST-sorted
  test "should get causes list voting status first page sorted by popularity" do
    create_incremental_voted_causes
    causes_ids = Cause.all.map(&:id).sort.reverse

    get :index, :sorting => :votes

    assert_not_nil assigns(:causes)
    assert_equal 5, assigns(:causes).size
    assert_equal causes_ids[0...5], assigns(:causes).map(&:id)
  end

  #LIST-sorted-count
  test "should get causes list voting status different page and count sorted by popularity" do
    create_incremental_voted_causes
    causes_ids = Cause.all.map(&:id).sort.reverse

    get :index, :page => 2, :per_page => 10, :sorting => :votes

    assert_not_nil assigns(:causes)
    assert_equal 10, assigns(:causes).size
    assert_equal causes_ids[10...20], assigns(:causes).map(&:id)
  end

  #LIST-filter
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

  #LIST-filter
  test "should get causes list inactive status filtered by category if admin" do
    user = create_admin_and_sign_in
    CauseCategory.make_many 2

    causes = Cause.make_many 3, :status => :inactive, :cause_category => CauseCategory.first
    Cause.make_many 3, :status => :raising_funds, :cause_category => CauseCategory.first
    Cause.make_many 3, :status => :completed, :cause_category => CauseCategory.last

    get :index, :status => :inactive, :category => CauseCategory.first.id

    assert_response :success
    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_equal_unordered causes.map(&:id), assigns(:causes).map(&:id)
  end

  #LIST-filter
  test "shouldnt get causes list inactive status filtered by category if not admin" do
    user = create_and_sign_in
    CauseCategory.make_many 2

    causes = Cause.make_many 3, :status => :inactive, :cause_category => CauseCategory.first
    Cause.make_many 3, :status => :raising_funds, :cause_category => CauseCategory.first
    Cause.make_many 3, :status => :completed, :cause_category => CauseCategory.last

    get :index, :status => :inactive, :category => CauseCategory.first.id

    assert_response :forbidden
  end

  #LIST-sorted
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

  #LIST-sorted
  test "should get causes list sorted alphabetically" do
    Cause.make :name => "C Cause"
    Cause.make :name => "B Cause"
    Cause.make :name => "A Cause"

    get :index, :sorting => :alphabetical

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end

  #LIST-sorted
  test "should get causes list sorted by charity rating" do
    Cause.make :charity => (Charity.make :rating => 3)
    Cause.make :charity => (Charity.make :rating => 4)
    Cause.make :charity => (Charity.make :rating => 5)

    get :index, :sorting => :rating

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end

  #LIST-sorted
  test "should get causes list sorted by completion percentage" do
    Cause.make :status => :raising_funds, :funds_needed => 1000, :funds_raised => 700
    Cause.make :status => :raising_funds, :funds_needed => 100, :funds_raised => 80
    Cause.make :status => :raising_funds, :funds_needed => 10000, :funds_raised => 9000

    get :index, :sorting => :completion, :status => :raising_funds

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end

  #LIST-sorted
  test "should get causes list sorted by funds needed" do
    Cause.make :status => :raising_funds, :funds_needed => 10
    Cause.make :status => :raising_funds, :funds_needed => 50
    Cause.make :status => :raising_funds, :funds_needed => 100

    get :index, :sorting => :funds_needed, :status => :raising_funds

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end

  #LIST-sorted
  test "should get causes list sorted by funds raised" do
    Cause.make :status => :raising_funds, :funds_raised => 10
    Cause.make :status => :raising_funds, :funds_raised => 50
    Cause.make :status => :raising_funds, :funds_raised => 100

    get :index, :sorting => :funds_raised, :status => :raising_funds

    assert_not_nil assigns(:causes)
    assert_equal 3, assigns(:causes).size
    assert_causes_returned_order_reverse
  end

  #LIST-limit
  test "should get causes list limiting item count if not admin" do
    Cause.make_many 60, :status => :active

    get :index, :per_page => 100, :status => :active

    assert_not_nil assigns(:causes)
    assert_equal 50, assigns(:causes).size
  end

  #LIST-limit
  test "should get causes list without limiting item count if admin" do
    create_admin_and_sign_in
    Cause.make_many 60, :status => :active

    get :index, :per_page => 100, :status => :active

    assert_not_nil assigns(:causes)
    assert_equal 60, assigns(:causes).size
  end

  #LIST-limit
  test "should get completed causes list without limiting" do
    Cause.make_many 60, :status => :completed

    get :index, :per_page => 100, :status => :completed

    assert_not_nil assigns(:causes)
    assert_equal 60, assigns(:causes).size
  end

  #LIST-filter
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

  private

  def assert_causes_returned_order_reverse(causes=assigns(:causes))
    assert_equal Cause.all.map(&:id).sort.reverse, causes.map(&:id)
  end

end