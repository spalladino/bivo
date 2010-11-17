require 'test_helper'
require 'money'

class TransactionsControllerTest < ActionController::TestCase
  def build_income_categories
    @shop_category = IncomeCategory.create! :name => "shop"
    @investment_category = IncomeCategory.create! :name => "investment"
  end

  test "should add an income transaction" do
    build_income_categories
    admin = create_admin_and_sign_in

    post :create,
    :transaction =>
    {
      :type               => "Income",
      :transaction_date   => "2010-10-10",
      :income_category_id => @shop_category.id,
      :shop_id            => Shop.make.id,
      :input_amount       => "1.22",
      :input_currency     => "GBP",
      :description        => "test"
    }

    assert_not_nil Income.first
    assert_response :found
  end

  test "shouldnt add an income transaction" do
    build_income_categories
    admin = create_admin_and_sign_in

    post :create,
    :transaction =>
    {
      :type               => "Income",
      :transaction_date   => "2010-11-11",
      :input_amount       => "1.31",
      :input_currency     => "GBP",
      :description        => "test"
    }

    assert_nil Income.first
    assert_response :ok
  end

  test "should add an expense transaction" do
    build_income_categories
    admin = create_admin_and_sign_in

    post :create,
    :transaction =>
    {
      :type                => "Expense",
      :transaction_date    => "2010-10-10",
      :expense_category_id => @shop_category.id,
      :paid_to             => "somebody",
      :input_amount        => "1.22",
      :input_currency      => "GBP",
      :description         => "test"
    }

    assert_not_nil Expense.first
    assert_response :found
  end

  test "shouldnt add an expense transaction" do
    build_income_categories
    admin = create_admin_and_sign_in

    post :create,
    :transaction =>
    {
      :type                => "Expense",
      :transaction_date    => "2010-10-10",
      :input_amount        => "1.22",
      :input_currency      => "GBP",
      :description         => "test"
    }

    assert_nil Expense.first
    assert_response :ok
  end

  test "shouldnt add a transaction if error in google currency conversion service" do
    build_income_categories
    admin = create_admin_and_sign_in

    Money.default_bank.stubs(:get_rate).raises Exception.new

    post :create,
    :transaction =>
    {
      :type                => "Expense",
      :transaction_date    => "2010-10-10",
      :expense_category_id => @shop_category.id,
      :paid_to             => "somebody",
      :input_amount        => "100",
      :input_currency      => "ARS",
      :description         => "test"
    }

    assert_nil Expense.first
    assert_response :ok
  end
end
