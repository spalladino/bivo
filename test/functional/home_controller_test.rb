require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  HTTP_ACCEPT_LANGUAGE = "es,es-AR,en-US,en;q=0.8"

  def setup
    @controller.stubs(:get_browser_accept_languages).returns(HTTP_ACCEPT_LANGUAGE)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get dashboard" do
    get :dashboard
    assert_response :success
  end

  test "should use browser language if not language setted before" do
    get :index

    assert_equal @request.session[:locale].to_sym, Language.preferred(HTTP_ACCEPT_LANGUAGE).id
  end

  test "should use english if any of the accepted languages are available" do
    @controller.stubs(:get_browser_accept_languages).returns("not_existing_lang")
    get :index
    
    assert_equal @request.session[:locale].to_sym, :en
  end
  #in this test I am assuming spanish and french are available
  test "shouldnt use english if the language is spanish or french" do
    @controller.stubs(:get_browser_accept_languages).returns("es")
    get :index

    assert_equal @request.session[:locale].to_sym, :es

    @request.session[:locale] = nil
    @controller.stubs(:get_browser_accept_languages).returns("fr")
    get :index

    assert_equal @request.session[:locale].to_sym, :fr
  end

  test "should change the language if the user choose another one" do
    get :index
    get :change_language, :language => "en"
    get :index

    assert_equal @request.session[:locale].to_sym, :en
  end

  test "should change the language to the user preferred language if a user logs in" do
    get :index
    user = create_charity_and_sign_in :preferred_language => :en
    get :index

    assert_equal @request.session[:locale].to_sym, :en
  end

  test "should persist the language on the current user if a user is logged in and choose another one" do
    get :index
    user = create_charity_and_sign_in :preferred_language => :en
    get :index
    get :change_language, :language => "fr"

    assert_equal @request.session[:locale].to_sym, :fr
    assert_equal Charity.find(user.id).preferred_language.to_sym, :fr    
  end
  
  test "should get stats without data" do
    get :stats
    assert_response :success
  end
  
  test "should get stats filtering by period" do
    ecat = ExpenseCategory.make_many(3).sort { |a,b| a.name <=> b.name }
    
    Expense.make :transaction_date => 2.month.ago, :expense_category => ecat.first
    e1 = Expense.make :expense_category => ecat.first
    e2 = Expense.make :expense_category => ecat.first
    e3 = Expense.make :expense_category => ecat.second
    
    get :stats
    assert_response :success
    
    assert_equal [e1, e2, e3], assigns(:expenses)
    assert_equal ecat.map(&:id), assigns(:expense_categories).map(&:id)
        
    assert_equal e1.amount + e2.amount, assigns(:expense_categories).first.amount
    assert_equal e3.amount, assigns(:expense_categories).second.amount
    assert_equal 0, assigns(:expense_categories).third.amount
  end
  
  test "should display all expense categories" do
    ecat = ExpenseCategory.make_many(3).sort { |a,b| a.name <=> b.name }

    Expense.make :transaction_date => 4.month.ago, :expense_category => ecat.first
    e1 = Expense.make :expense_category => ecat.first
    e2 = Expense.make :expense_category => ecat.first
    e3 = Expense.make :expense_category => ecat.second
    
    get :stats, :period => 'last_month'
    assert_response :success
    
    assert_equal ecat.map(&:id), assigns(:expense_categories).map(&:id)
    assert_equal 0, assigns(:expense_categories).first.amount
    assert_equal 0, assigns(:expense_categories).second.amount
    assert_equal 0, assigns(:expense_categories).third.amount
  end
end
