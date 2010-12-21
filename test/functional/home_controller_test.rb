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
    post :change_language, :language => "en"
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
    post :change_language, :language => "fr"
  
    assert_equal @request.session[:locale].to_sym, :fr
    assert_equal Charity.find(user.id).preferred_language.to_sym, :fr    
  end
  
  test "should use gbp if no currency set" do
    get :index
    assert_equal :GBP, session[:currency].to_sym
  end
  
  test "should set usd in current session" do
    post :change_currency, :currency => 'USD'
    get :index
    get :jobs
    assert_equal :USD, session[:currency].to_sym
  end
  
  test "should redirect to referrer when changing currency" do
    get :jobs
    @request.env['HTTP_REFERER'] = 'http://test.host/jobs'
    
    post :change_currency, :currency => 'USD'
    assert_redirected_to :action => :jobs
    assert_equal :USD, session[:currency].to_sym
  end
  
  test "should persist preferred currency in signed in user" do
    user = create_and_sign_in
    assert_equal :GBP, user.preferred_currency.to_sym
    post :change_currency, :currency => "USD"

    assert_equal :USD, session[:currency].to_sym
    assert_equal :USD, user.reload.preferred_currency.to_sym
  end
  
  test "should not persist invalid currency" do
    user = create_and_sign_in
    assert_equal :GBP, user.preferred_currency.to_sym
    post :change_currency, :currency => "XXX"

    assert_equal :GBP, session[:currency].to_sym
    assert_equal :GBP, user.preferred_currency.to_sym
  end
  
  test "should get stats without data" do
    get :stats
    assert_response :success
    
    assert_not_nil assigns(:cash_reserves)
  end
  
  test "should get expense stats filtering by period" do
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
    assert_equal [e1, e2, e3].sum(&:amount), assigns(:expenses_total)    
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
    assert_equal 0, assigns(:expenses_total)
  end
  
  test "should get income stats filtering by period" do
    icat = IncomeCategory.make_many(3).concat([IncomeCategory.get_shop_category]).sort { |a,b| a.name <=> b.name }
    icat_ = icat.select { |c| c != IncomeCategory.get_shop_category }
    
    Income.make :investment, :transaction_date => 4.month.ago, :income_category => icat_.first
    i1 = Income.make :investment, :income_category => icat_.first
    i2 = Income.make :investment, :income_category => icat_.first
    i3 = Income.make :investment, :income_category => icat_.second
    
    get :stats
    assert_response :success
    
    assert_equal [i1, i2, i3], assigns(:revenues)
    assert_equal icat.map(&:id), assigns(:revenue_categories).map(&:id)
    assigns(:revenue_categories).reject { |c| c.id == IncomeCategory.get_shop_category.id }

    assert_equal i1.revenue_amount + i2.revenue_amount, assigns(:revenue_categories).first.revenue_amount
    assert_equal i3.revenue_amount, assigns(:revenue_categories).second.revenue_amount
    assert_equal 0, assigns(:revenue_categories).third.revenue_amount
    assert_equal [i1, i2, i3].sum(&:revenue_amount), assigns(:revenues_total)
  end
  
  test "should display all income categories in revenue" do
    icat = IncomeCategory.make_many(3).concat([IncomeCategory.get_shop_category]).sort { |a,b| a.name <=> b.name }
    icat_ = icat.select { |c| c != IncomeCategory.get_shop_category }

    Income.make :investment, :transaction_date => 4.month.ago, :income_category => icat_.first
    i1 = Income.make :investment, :income_category => icat_.first
    i2 = Income.make :investment, :income_category => icat_.first
    i3 = Income.make :investment, :income_category => icat_.second

    get :stats, :period => 'last_month'
    assert_response :success

    assert_equal icat.map(&:id), assigns(:revenue_categories).map(&:id)
    assigns(:revenue_categories).reject { |c| c.id == IncomeCategory.get_shop_category.id }

    assert_equal 0, assigns(:revenue_categories).first.revenue_amount
    assert_equal 0, assigns(:revenue_categories).second.revenue_amount
    assert_equal 0, assigns(:revenue_categories).third.revenue_amount
    assert_equal 0, assigns(:revenues_total)
   end
end
