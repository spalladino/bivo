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

end

