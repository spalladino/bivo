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
  
  test "category name should be translated" do
    c = ShopCategory.make
    Translation.create! :translated_type => ShopCategory.name, :translated_id => c.id, :translated_field => 'name', :language => 'es', :value => "Categoria", :pending => true
    
    assert_equal "Categoria", ShopCategory.translated('es').find(c.id).name
  end
end


