require 'test_helper'

class ShopCategoryTest < ActiveSupport::TestCase
  test "shop can have multiple categories" do
    a = ShopCategory.make
    b = ShopCategory.make
    s = Shop.make
    
    s.categories << a
    s.categories << b
    
    s.save!
  end
  
  test "list categories as case insensitve" do
    a1 = ShopCategory.make :name => 'a1'
    b = ShopCategory.make :name => 'b'
    a2 = ShopCategory.make :name => 'A2'
    
    assert_equal a1, ShopCategory.roots.first
    assert_equal a2, ShopCategory.roots.second
    assert_equal b, ShopCategory.roots.third
  end
  
  test "validate empty name" do
    a = ShopCategory.make_unsaved :name => ''
    assert !a.save
  end
    
  test "category should be internationalized" do
    c = ShopCategory.make :name => 'Category'
    c.save_translation :es, :name => 'Categoria'
    c.save_translation :fr, :name => 'Categorie'
    
    assert_equal 'Category', ShopCategory.first.name
    assert_equal 'Categoria', ShopCategory.translated(:es).first.name
    assert_equal 'Categorie', ShopCategory.translated(:fr).first.name
  end
end


