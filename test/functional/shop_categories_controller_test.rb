require 'test_helper'

class ShopCategoriesControllerTest < ActionController::TestCase
  def build_categories
    @a = ShopCategory.create! :name => 'a'
    @a1 = ShopCategory.create! :name => 'a1', :parent => @a
    @a2 = ShopCategory.create! :name => 'a2', :parent => @a
    @a21 = ShopCategory.create! :name => 'a21', :parent => @a2
                                                               
    @c = ShopCategory.create! :name => 'c'                 
    @c1 = ShopCategory.create! :name => 'c1', :parent => @c
     
    @b = ShopCategory.create! :name => 'b'
  end
  
  test "non-admin can edit shop categories" do
    create_and_sign_in
    get :edit
    assert_response :forbidden
  end
    
  test "edit show roots by default (sorted by name)" do
    build_categories
    create_admin_and_sign_in
    
    get :edit
    
    assert_response :success
    assert_nil assigns(:category)
    assert_equal [], assigns(:path)
    assert_equal [@a,@b,@c], assigns(:child_categories)
  end
  
  test "edit show current category and it childs" do
    build_categories
    create_admin_and_sign_in
    
    get :edit, :id => @a.id
    
    assert_response :success
    assert_equal @a, assigns(:category)
    assert_equal [@a], assigns(:path)
    assert_equal [@a1,@a2], assigns(:child_categories)
  end
  
  test "path starts from root and goes up to current" do
    build_categories
    create_admin_and_sign_in
    
    get :edit, :id => @a21.id
    
    assert_response :success
    assert_equal @a21, assigns(:category)
    assert_equal [@a,@a2,@a21], assigns(:path)
    assert_equal [], assigns(:child_categories)
  end
  
  test "can create categories at root level" do
    build_categories
    create_admin_and_sign_in

    assert_difference 'ShopCategory.count' do
      post :create, :newcategory => { :parent_id => '', :name => 'new-category' }
      
      assert_not_nil ShopCategory.find_by_name('new-category')
    end
    
    assert_response :redirect
  end
  
  test "can create categories at other levels" do
    build_categories
    create_admin_and_sign_in

    assert_difference 'ShopCategory.count' do
      post :create, :newcategory => { :parent_id => @b.id, :name => 'new-category' }

      @b.reload
      assert_equal 'new-category', @b.children.first.name
    end

    assert_response :redirect
  end
end
