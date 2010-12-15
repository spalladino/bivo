require 'test_helper'

class ShopsControllerSearchTest < ActionController::TestCase

  def self.controller_class; ShopsController; end

  #INDEX-localized
  test "should translate category in index" do

    categ = ShopCategory.make_translated :name => 'books', :translations => {:es => { :name => 'libros' } }
    other = ShopCategory.make
    
    Shop.make_many 3, :categories => [categ]
    Shop.make_many 2, :categories => [other]

    set_locale :es

    get :index, :category_field => categ.id

    assert_not_nil assigns(:shops)
    assert_equal 3, assigns(:shops).size

    assert_not_nil assigns(:category)
    assert_select "a[href='javascript:filterByCategory(#{categ.id})']", 'libros'
  end
  
  #INDEX-inactive
  test "shouldnt get inactive shops in list if not admin" do

    Shop.make_many 3, :status => :inactive
    Shop.make_many 3

    get :index

    assert_not_nil assigns(:shops)
    assert_equal 3, assigns(:shops).size
  end

  #INDEX-inactive
  test "should get inactive shops in list if admin" do
    user = create_admin_and_sign_in

    Shop.make_many 3, :status => :inactive
    Shop.make_many 3

    get :index

    assert_not_nil assigns(:shops)
    assert_equal 6, assigns(:shops).size

  end
  
  #INDEX-localized
  test "should list shops using current locale in index" do
    s = Shop.make_translated :description => "description", :translations => {:es => {:description => "descripcion"}}
    
    set_locale :es
    get :index
    
    assert_not_nil assigns(:shops)
    assert_equal "descripcion", assigns(:shops).first.description
  end


  #SEARCH-inactive
  test "shouldnt get inactive shops in search" do

    Shop.make_many 3, :status => :inactive
    Shop.make_many 3
    get :search

    assert_not_nil assigns(:shops)
    assert_equal 3, assigns(:shops).size
  end

  #SEARCH-localized
  test "should list shops using current locale in search" do
    s = Shop.make_translated :description => "description", :translations => {:es => {:description => "descripcion"}}
    
    set_locale :es
    get :search
    
    assert_not_nil assigns(:shops)
    assert_equal "descripcion", assigns(:shops).first.description
  end

  #SEARCH-localized
  test "should search shops using current locale" do
    s1 = Shop.make_translated :description => "books", :translations => {:es => {:description => "libros"}}
    s2 = Shop.make_translated :description => "cars", :translations => {:es => {:description => "autos"}}

    set_locale :es
    get :search, :search_word => 'libro'

    assert_not_nil assigns(:shops)
    assert_equal 1, assigns(:shops).size
    assert_equal 'libros', assigns(:shops).first.description
  end
  
  #SEARCH-localized
  test "should search shops using default locale if no valid translation is present" do
    s1 = Shop.make_translated :description => "books", :translations => {:es => {:description => "libros"}}
    s1.description = "cars"
    s1.save!

    set_locale :es
    get :search, :search_word => 'car'

    assert_not_nil assigns(:shops)
    assert_equal 1, assigns(:shops).size
    assert_equal 'cars', assigns(:shops).first.description
  end
  
  #SEARCH-fields
  test "should search in shop url" do
    s1 = Shop.make :url => 'books.com'
    s2 = Shop.make :url => 'cars.com'
    
    get :search, :search_word => 'books.com'
    
    assert_not_nil assigns(:shops)
    assert_equal 1, assigns(:shops).size
    assert_equal s1.id, assigns(:shops).first.id
  end
  
  #SEARCH-fields
  test "should search in shop short url" do
    s1 = Shop.make :short_url => 'books'
    s2 = Shop.make :short_url => 'cars'
    
    get :search, :search_word => 'books'
    
    assert_not_nil assigns(:shops)
    assert_equal 1, assigns(:shops).size
    assert_equal s1.id, assigns(:shops).first.id
  end
  
  
  #SEARCH-categories
  test "should search in shop category names" do
    c1 = ShopCategory.make :name => 'books'
    c2 = ShopCategory.make :name => 'cars'
    s1 = Shop.make :categories => [c1]
    s2 = Shop.make :categories => [c2]    
    
    get :search, :search_word => 'book'
    
    assert_not_nil assigns(:shops)
    assert_equal 1, assigns(:shops).size
    assert_equal s1.id, assigns(:shops).first.id
  end
  
  #SEARCH-categories-localized
  test "should search in localized shop category names" do
    c1 = ShopCategory.make_translated :name => 'books', :translations => {:es => {:name => 'libros'}}
    c2 = ShopCategory.make_translated :name => 'cars', :translations => {:es => {:name => 'autos'}}
    s1 = Shop.make :categories => [c1]
    s2 = Shop.make :categories => [c2]    

    set_locale :es    
    get :search, :search_word => 'libro'
    
    assert_not_nil assigns(:shops)
    assert_equal 1, assigns(:shops).size
    assert_equal s1.id, assigns(:shops).first.id
  end


end

