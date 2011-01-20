require 'test_helper'

class IncomeCategoriesControllerTest < ActionController::TestCase

  test "should add new sources" do
    admin = create_admin_and_sign_in
    IncomeCategory.get_shop_category
    post :create, :income_category => {:name => "pepito"}

    assert_equal 2,IncomeCategory.count

  end


  test "shouldnt add new sources with reserved name" do
    admin = create_admin_and_sign_in
    IncomeCategory.get_shop_category
    post :create, :income_category => {:name => IncomeCategory::ShopName}

    assert_equal 1,IncomeCategory.count

  end

  test "should delete sources" do
    admin = create_admin_and_sign_in
    IncomeCategory.get_shop_category
    ic = IncomeCategory.create(:name => "pepe")
    post :destroy, :id => ic.id

    assert_equal 1,IncomeCategory.count

  end

  test "shouldnt delete reserve source" do
    admin = create_admin_and_sign_in
    IncomeCategory.get_shop_category
    post :destroy, :id => IncomeCategory.first.id

    assert_equal 1,IncomeCategory.count

  end


  test "should update sources" do
    admin = create_admin_and_sign_in
    IncomeCategory.get_shop_category
    ic = IncomeCategory.create(:name => "pepe")
    post :update,:id => ic.id,:income_category => {:name => "pepes"}

    assert_equal 2,IncomeCategory.count
    assert_equal "pepes",ic.reload.name

  end

  test "shouldnt update reserved sources" do
    admin = create_admin_and_sign_in
    IncomeCategory.get_shop_category
    post :update,:id => IncomeCategory.first.id,:income_category => {:name => "pepes"}

    assert_equal 1,IncomeCategory.count
    assert_equal IncomeCategory::ShopName,IncomeCategory.first.name

  end


end

