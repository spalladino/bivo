require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  def build_income_categories
    @shop_category = IncomeCategory.create! :name => "shop"
    @investment_category = IncomeCategory.create! :name => "investment"
  end

  test "should edit a charity from admin" do
    admin = create_admin_and_sign_in
    charity = Charity.make
    
    post :update_user,
    :id => charity.id,
    :user =>
    {
      :type                  => "Charity",
      :email                 => "char@bivotest.com",
      :password              => "123456",
      :password_confirmation => "123456",
      :charity_name          => "test",
      :charity_website       => "http://www.test.com",
      :charity_category_id   => CharityCategory.make.id,
      :short_url             => "abc",
      :charity_type          => "def",
      :tax_reg_number        => 123456,
      :country_id            => Country.make.id,
      :city                  => "Bs As",
      :description           => "Description test"
    }

    assert_equal Charity.find(charity.id).email, "char@bivotest.com"
    assert_response :found

  end

  test "shouldnt edit a charity from admin" do
    charity = Charity.make

    post :update_user,
    :id => charity.id,
    :user =>
    {
      :type                  => "Charity",
      :email                 => "char@bivotest.com",
      :password              => "123456",
      :password_confirmation => "123456",
      :charity_name          => "test",
      :charity_website       => "http://www.test.com",
      :charity_category_id   => CharityCategory.make.id,
      :short_url             => "abc",
      :charity_type          => "def",
      :tax_reg_number        => 123456,
      :country_id            => Country.make.id,
      :city                  => "Bs As",
      :description           => "Description test"
    }

    assert_not_equal Charity.find(charity.id).email, "char@bivotest.com"
    assert_response :forbidden
  end

  test "should edit a personal user from admin" do
    admin = create_admin_and_sign_in
    personal_user = PersonalUser.make

    post :update_user,
    :id => personal_user.id,
    :user =>
    {
      :email                 => "aa@bb.com",
      :first_name            => "juan",
      :last_name             => "rodriguez"
    }

    assert_equal PersonalUser.find(personal_user.id).email, "aa@bb.com"
    assert_response :found
  end

  test "shouldnt edit a personal user from admin" do
    personal_user = PersonalUser.make

    post :update_user,
    :id => personal_user.id,
    :user =>
    {
      :email                 => "aa@bb.com",
      :first_name            => "juan",
      :last_name             => "rodriguez"
    }

    assert_not_equal PersonalUser.find(personal_user.id).email, "aa@bb.com"
    assert_response :forbidden
  end

  test "should add a charity from admin" do
    admin = create_admin_and_sign_in

    post :create_charity,
    :charity =>
    {
      :email                 => "char@bivotest.com",
      :password              => "123456",
      :password_confirmation => "123456",
      :charity_category_id   => CharityCategory.make.id,
      :charity_name          => "test",
      :charity_website       => "http://www.test.com",
      :short_url             => "abc",
      :charity_type          => "def",
      :tax_reg_number        => 123456,
      :country_id            => Country.make.id,
      :city                  => "Bs As",
      :description           => "Description test"
    }

    assert_not_nil Charity.find_by_email("char@bivotest.com")
    assert_response :found
  end

  test "shouldnt add a charity from admin" do
    post :create_charity,
    :charity =>
    {
      :email                 => "char@bivotest.com",
      :password              => "123456",
      :password_confirmation => "123456",
      :charity_category_id   => CharityCategory.make.id,
      :charity_name          => "test",
      :charity_website       => "http://www.test.com",
      :short_url             => "abc",
      :charity_type          => "def",
      :tax_reg_number        => 123456,
      :country_id            => Country.make.id,
      :city                  => "Bs As",
      :description           => "Description test"
    }

    assert_nil Charity.find_by_email("char@bivotest.com")
    assert_response :forbidden
  end


  test "should add a personal user from admin" do
    admin = create_admin_and_sign_in

    post :create_personal_user,
    :personal_user =>
    {
      :email                 => "char@bivotest.com",
      :password              => "123456",
      :password_confirmation => "123456",
      :first_name            => "juan",
      :last_name             => "rodriguez"
    }

    assert_not_nil PersonalUser.find_by_email("char@bivotest.com")
    assert_response :found
  end

  test "shouldnt add a personal user from admin" do
    post :create_personal_user,
    :personal_user =>
    {
      :email                 => "char@bivotest.com",
      :password              => "123456",
      :password_confirmation => "123456",
      :first_name            => "juan",
      :last_name             => "rodriguez"
    }

    assert_nil PersonalUser.find_by_email("char@bivotest.com")
    assert_response :forbidden
  end

  test "should search a user from admin" do
    admin = create_admin_and_sign_in

    get :index
    assert_response :ok
  end

  test "shouldnt search a user from admin" do
    get :index
    assert_response :forbidden
  end

  test "should add an income transaction" do
    build_income_categories
    admin = create_admin_and_sign_in

    post :create_income_and_expense,
    :transaction =>
    {
      :type               => "Income",
      :transaction_date   => "2010-10-10",
      :income_category_id => @shop_category.id,
      :shop_id            => Shop.make.id,
      :amount             => "1.22",
      :description        => "test"
    }

    assert_not_nil Income.first
    assert_response :found
  end

  test "shouldnt add an income transaction" do
    build_income_categories
    admin = create_admin_and_sign_in

    post :create_income_and_expense,
    :transaction =>
    {
      :type               => "Income",
      :transaction_date   => "2010-11-11",
      :amount             => "1.31",
      :description        => "test"
    }

    assert_nil Income.first
    assert_response :ok
  end

  test "should add an expense transaction" do
    build_income_categories
    admin = create_admin_and_sign_in

    post :create_income_and_expense,
    :transaction =>
    {
      :type                => "Expense",
      :transaction_date    => "2010-10-10",
      :expense_category_id => @shop_category.id,
      :paid_to             => "somebody",
      :amount              => "1.22",
      :description         => "test"
    }

    assert_not_nil Expense.first
    assert_response :found
  end

  test "shouldnt add an expense transaction" do
    build_income_categories
    admin = create_admin_and_sign_in

    post :create_income_and_expense,
    :transaction =>
    {
      :type                => "Expense",
      :transaction_date    => "2010-10-10",
      :amount              => "1.22",
      :description         => "test"
    }

    assert_nil Expense.first
    assert_response :ok
  end
end
