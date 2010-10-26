require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  #DETAILS
  test "should get details" do
    shop = Shop.make :short_url => "foobar"

    get :details, :short_url => "foobar"

    assert_not_nil assigns(:shop)
    assert_equal assigns(:shop), shop
    assert_response :success
  end

  #NEW
  test "should go to new shop" do
    #TODO completar
    assert_response :ok
  end

  #NEW
  test "shouldnt go to new shop" do
    #TODO completar
    assert_response :ok
  end

  #EDIT
  test "should go to edit shop" do
    #TODO completar
    assert_response :ok
  end

  #EDIT
  test "shouldnt go to edit shop" do
    #TODO completar
    assert_response :ok
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

