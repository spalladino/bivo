require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  test "admin can get new shop" do
    create_admin_and_sign_in
    get :new
    assert_response :success
    assert_not_nil assigns(:shop)
  end
  
  test "user cannot get new shop" do
    create_and_sign_in
    get :new
    assert_response :found
  end
  
  test "admin can edit shop" do
    create_admin_and_sign_in
    id = Shop.make.id
    get :edit, :id => id

    assert_response :success
    assert_not_nil assigns(:shop)
    assert_equal id, assigns(:shop).id
  end
  
  test "user cannot edit shop" do
    create_and_sign_in
    id = Shop.make.id
    get :edit, :id => id

    assert_response :found
  end
  
  test "should create new shop" do
    create_admin_and_sign_in
    
  end
  
  test "should not create new shop with no name" do
  end

  test "should update shop" do
  end
  
  test "should not update shop with repeated name" do
  end

end

