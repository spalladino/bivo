require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  test "admin can get new shop" do
    create_admin_and_sign_in
    get :new
    assert_response :success
    assert_not_nil assigns(:shop)
    assert_not_nil assigns(:categories)
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
    assert_equal :active,Shop.find_by_name("Shopname").status
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

  test 'should not create shop when name is unavailable' do
    s = Shop.make
    create_admin_and_sign_in
    post :create, :shop => {
        :name => s.name,
        :description => "Testing shop",
        :short_url => "shop",
        :url => "www.example.com",
        :redirection => "purchase_button",
        :comission_value => 10.0,
        :comission_details => "comission",
        :comission_kind => "percentage"}
    assert_equal 1, Shop.count
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

  test "should update shop with many categories" do
    create_admin_and_sign_in
    categories = ShopCategory.make_many(5)
    shop = Shop.make :category_ids => [categories[1].id, categories[3].id]

    post :update, :id => shop.id, :shop => {
      :name => "Shopname",
      :description => shop.description,
      :category_ids => [ categories[1].id, categories[2].id, categories[4].id ]
    }

    shop.reload

    assert_equal "Shopname", shop.name
    assert_includes shop.categories, categories[1]
    assert_includes shop.categories, categories[2]
    assert_includes shop.categories, categories[4]
    assert_equal 3, shop.categories.count
    assert_response :found
  end

  test "should remove all categories from shop" do
    create_admin_and_sign_in
    categories = ShopCategory.make_many(5)
    shop = Shop.make :category_ids => [categories[1].id, categories[3].id]

    post :update, :id => shop.id, :shop => {
      :name => "Shopname",
      :description => shop.description,
    }

    shop.reload

    assert_equal "Shopname", shop.name
    assert_equal 0, shop.categories.count
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

  #DELETE
  test "should delete shop" do
    create_admin_and_sign_in
    shop = Shop.make

    assert_difference('Shop.count', -1) do
      post :destroy, :id => shop.id
    end

    assert_response :found
  end

  #DELETE
  [:active, :inactive].each do |status|
    test "should not delete shop that is #{status} with raising founds" do
      shop = Shop.make :status => status

      income = Income.make(:shop => shop,:input_amount => 100.0,:income_category => IncomeCategory.get_shop_category)

      create_admin_and_sign_in
      assert_difference('Shop.count', 0) do
        post :destroy, :id => shop.id
      end

      assert_equal status, shop.reload.status
      assert_response :found
      assert_match /not be deleted/, flash[:error]
    end
  end

  #DELETE
  test "should not delete if not admin" do
    shop = Shop.make
    create_and_sign_in

    assert_difference('Shop.count', 0) do
      post :destroy, :id => shop.id
    end

    assert_equal :active,shop.reload.status
    assert_response :forbidden
  end


  #HOME/DETAILS

[:home,:details].each do |action|
  test "should get #{action}" do
    shop = Shop.make :short_url => "foobar", :redirection => :search_box

    get action, :short_url => "foobar"

    assert_not_nil assigns(:shop)
    assert_equal assigns(:shop), shop
    assert_response :success
  end


  test "should get #{action} of inactive if admin" do
    create_admin_and_sign_in
    shop = Shop.make :short_url => "foobar", :status => :inactive, :redirection => :search_box

    get action, :short_url => "foobar"

    assert_not_nil assigns(:shop)
    assert_equal assigns(:shop), shop
    assert_response :success
  end

  test "should not get #{action} of inactive if not admin" do
    create_and_sign_in
    shop = Shop.make :short_url => "foobar", :status => :inactive

    get action, :short_url => "foobar"

    assert_response :not_found
  end
end

  #SHOW
  test "show shop" do
    shop = Shop.make
    get :show, :id => shop.id
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
  test "should not activate because not admin" do
    user = create_and_sign_in
    id = Shop.make(:status=>:inactive).id
    post :activate, :id => id
    assert_response :forbidden
    assert_equal :inactive,Shop.find_with_inactives(id).status
  end

    #DEACTIVATE
  test "should deactivate" do
    user = create_admin_and_sign_in
    id = Shop.make.id
    post :deactivate, :id => id
    assert_response :found
    assert_equal :inactive,Shop.find_with_inactives(id).status
   end

  #DEACTIVATE
  test "should not deactivate" do
    user = create_and_sign_in
    id = Shop.make.id
    post :deactivate, :id => id
    assert_response :forbidden
    assert_equal :active,Shop.find(id).status
  end


  test "should render edit categories partial" do
    create_admin_and_sign_in
    get :edit_categories
    assert assigns(:shop).new_record?
    assert_response :success
  end

  #LIST-filter
  test "shouldnt get inactive shops in list if not admin" do
    user = create_and_sign_in

    Shop.make_many 3, :status => :inactive
    Shop.make_many 3

    get :index

    assert_not_nil assigns(:shops)
    assert_equal 3, assigns(:shops).size
  end

  #LIST-filter
  test "should get inactive shops in list if admin" do
    user = create_admin_and_sign_in

    Shop.make_many 3, :status => :inactive
    Shop.make_many 3

    get :index

    assert_not_nil assigns(:shops)
    assert_equal 6, assigns(:shops).size

  end

  #LIST-search
  test "shouldnt get inactive shops in search" do
    user = create_admin_and_sign_in

    Shop.make_many 3, :status => :inactive
    Shop.make_many 3
    get :search

    assert_not_nil assigns(:shops)
    assert_equal 3, assigns(:shops).size
  end

end

