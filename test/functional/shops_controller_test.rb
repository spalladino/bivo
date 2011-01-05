require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  #HOME/DETAILS

[:home,:details].each do |action|
  test "should get #{action}" do
    shop = Shop.make :short_url => "foobar", :redirection => :search_box
    Income.make :shop, :shop => shop

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
    shop = Shop.make :short_url => "foobar", :status => :inactive, :name => 'shop name'

    get action, :short_url => "foobar"

    assert_not_nil assigns(:shop)
    assert_equal assigns(:shop), shop
    assert_equal assigns(:kind), 'shop'
    assert_equal assigns(:name), 'shop name'

    assert_select '#page_inactive', _('The') + ' shop shop name ' + _('is inactive.')
    assert_select '#doubts_contact', _('For any doubts, please contact') + ' info@bivo.org'

    assert_response :success
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
  
  test "admin should get inactive shops in list" do
    create_admin_and_sign_in
    s_a = Shop.make :name => 'aaa'
    s_i = Shop.make :name => 'bbb', :status => :inactive
    
    get :index
    
    assert_equal [s_a, s_i], assigns(:shops)
  end
  
  test "guests should not get inactive shops in list" do
    s_a = Shop.make
    s_i = Shop.make :status => :inactive

    get :index

    assert_equal [s_a], assigns(:shops)
  end
  
  test "admin should get list filtered by category" do
    create_admin_and_sign_in
    s_a = Shop.make :name => 'aaa'
    s_i = Shop.make :name => 'bbb', :status => :inactive
    Shop.make
    Shop.make :status => :inactive
    c = ShopCategory.make
    s_a.categories << c
    s_a.save!
    s_i.categories << c
    s_i.save!
    
    get :index, :category_field => c.id
    
    assert_equal [s_a, s_i], assigns(:shops)    
  end
  
  test "guests should get list filtered by category" do
    s_a = Shop.make :name => 'aaa'
    s_i = Shop.make :name => 'bbb', :status => :inactive
    Shop.make
    Shop.make :status => :inactive
    c = ShopCategory.make
    s_a.categories << c
    s_a.save!
    s_i.categories << c
    s_i.save!
    
    get :index, :category_field => c.id
    
    assert_equal [s_a], assigns(:shops)    
  end

end

