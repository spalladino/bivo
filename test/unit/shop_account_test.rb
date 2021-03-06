require 'test_helper'

class ShopAccountTest < ActiveSupport::TestCase

  test "shop income blueprint works" do
    income = Income.make(:shop)
    assert_equal IncomeCategory.get_shop_category.id, income.income_category_id
    assert_not_nil income.shop
  end

  test "shop account is created together with shop entity" do
    s = nil
    a = nil
    assert_difference 'ShopAccount.count' do
      s = Shop.make
    end
    
    assert_no_difference 'ShopAccount.count' do
      a = Account.shop_account s
    end
    assert_not_nil a
    assert_equal s, a.shop
    assert_equal 0.to_d, a.balance
    assert_instance_of ShopAccount, a
    assert_equal s.name, a.name
  end
  
  test "creating incomes moves 95% amount to cash pool" do
    income = Income.make :shop, :input_amount => 100
    
    shop_movement = Account.shop_account(income.shop).movements.first
    cash_pool_movement = Account.cash_pool_account.movements.first
    
    assert_movement -95, -95, shop_movement
    assert_movement 95, 95, cash_pool_movement
    
    assert_equal income, shop_movement.transaction
    assert_equal income, cash_pool_movement.transaction
  end
  
  test "creating incomes moves 5% amount to cash reserves" do
    income = Income.make :shop, :input_amount => 100

    shop_movement = Account.shop_account(income.shop).movements.second
    cash_reserves_movement = Account.cash_reserves_account.movements.first
    
    assert_movement -5, -100, shop_movement
    assert_movement 5, 5, cash_reserves_movement
    
    assert_equal income, shop_movement.transaction
    assert_equal income, cash_reserves_movement.transaction
  end
end
