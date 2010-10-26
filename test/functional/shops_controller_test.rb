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
  end
  
  test "should not create new shop with no name" do
  end

  test "should update shop" do
  end
  
  test "should not update shop with repeated name" do
  end

  #DETAILS
  test "should get details" do
    shop = Shop.make :short_url => "foobar"

    get :details, :short_url => "foobar"

    assert_not_nil assigns(:shop)
    assert_equal assigns(:shop), shop
    assert_response :success
  end

  #SHOW
  test "show shop" do
    shop = Shop.make
    get :show, :id => shop.id
    assert_response :ok
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

  #ACTIVATE
  test "should activate" do
    user = create_admin_and_sign_in
    id = Shop.make(:status=>:inactive).id
    post :activate, :id => id
    assert_response :found
    assert_equal :active,Shop.find(id).status
  end

  #ACTIVATE
  test "should not activate" do
    user = create_and_sign_in
    id = Shop.make(:status=>:inactive).id
    post :activate, :id => id
    assert_response :forbidden
    assert_equal :inactive,Shop.find(id).status
  end


  #DEACTIVATE
  test "should deactivate" do
    user = create_admin_and_sign_in
    id = Shop.make(:status=>:active).id
    post :deactivate, :id => id
    assert_response :found
    assert_equal :inactive,Shop.find(id).status
   end

  #DEACTIVATE
  test "should not deactivate" do
    user = create_and_sign_in
    id = Shop.make(:status=>:active).id
    post :deactivate, :id => id
    assert_response :forbidden
    assert_equal :active,Shop.find(id).status
  end

end

