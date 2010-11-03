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
    assert_response :forbidden
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

    assert_response :forbidden
  end
  
  test "should create new shop" do
    create_admin_and_sign_in
    assert_difference('Shop.count') do
      post :create, :shop => {
        :name => "Shopname",
        :description => "Testing shop",
        :short_url => "shop",
        :url => "www.example.com",
        :redirection => "purchase_button",
        :comission_value => 10.0,
        :comission_details => "comission",
        :comission_kind => "percentage"
      } 
    end
    
    assert_response :found
  end
  
  test "should create new shop with places" do
    create_admin_and_sign_in
    countries = Country.make_many(2)
    assert_difference('Shop.count') do
      post :create, :shop => {
        :name => "Shopname",
        :description => "Testing shop",
        :short_url => "shop",
        :url => "www.example.com",
        :redirection => "purchase_button",
        :comission_value => 10.0,
        :comission_details => "comission",
        :comission_kind => "percentage",
        :country_ids => countries.map(&:id)
      } 
    end
    
    assert_response :found
    
    shop = Shop.first
    assert_not_nil shop
    assert_equal countries.map(&:id).sort, shop.countries.map(&:id).sort
  end
  
  test "should not create new shop with no name" do
    create_admin_and_sign_in
    post :create, :shop => {
      :name => "",
      :description => "Testing shop",
      :short_url => "shop"} 
    
    assert_equal 0, Shop.count
    assert_response :success
  end

  test "should update shop" do
    create_admin_and_sign_in
    shop = Shop.make

    post :update, :id => shop.id, :shop => {
      :name => "Shopname",
      :description => shop.description,
      :short_url => shop.short_url } 
    
    assert_equal "Shopname", shop.reload.name
    assert_response :found
  end
  
  test "should update shop with places and worldwide" do
    create_admin_and_sign_in
    countries = Country.make_many(3)
    shop = Shop.make :country_ids => [countries[0].id, countries[1].id]

    post :update, :id => shop.id, :shop => {
      :name => "Shopname",
      :description => shop.description,
      :short_url => shop.short_url,
      :country_ids => [countries[1].id, countries[2].id],
      :worldwide => true 
    } 
    
    shop = shop.reload
    
    assert_equal "Shopname", shop.name
    assert_equal [countries[1].id, countries[2].id].sort, shop.countries.map(&:id).sort, "Countries ids do not match"
    assert_equal true, shop.worldwide
    assert_response :found
  end
  
  test "should update shop removing all places" do
    create_admin_and_sign_in
    countries = Country.make_many(3)
    shop = Shop.make :country_ids => countries.map(&:id)

    post :update, :id => shop.id, :shop => {
      :name => "Shopname",
      :description => shop.description,
      :short_url => shop.short_url
    } 
    
    shop = shop.reload
    
    assert_equal "Shopname", shop.name
    assert_equal [], shop.countries.map(&:id), "Countries ids do not match"
    assert_response :found
  end
  
  test "should not update shop with no description" do
    create_admin_and_sign_in
    shop = Shop.make :name => "Shopname"

    post :update, :id => shop.id, :shop => {
      :name => "",
      :description => shop.description,
      :short_url => shop.short_url } 
    
    assert_equal "Shopname", shop.reload.name
    assert_response :success
  end
  
  test "should delete shop" do
    create_admin_and_sign_in
    shop = Shop.make
    
    assert_difference('Shop.count', -1) do
      post :destroy, :id => shop.id
    end
    
    assert_response :found
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

