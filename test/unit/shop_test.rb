require 'test_helper'

class ShopTest < ActiveSupport::TestCase
  def build_categories
    @a = ShopCategory.make
    @a1 = ShopCategory.make :parent => @a
    @a11 = ShopCategory.make :parent => @a1
    @a2 = ShopCategory.make :parent => @a
    @b = ShopCategory.make
  end

  test "should make shop" do
    Shop.make
  end
  
  test "shop should be member of parent categories" do
    build_categories
    
    s = Shop.make
    
    s.categories << @a11
    
    assert_includes s.categories, @a
    assert_includes s.categories, @a1
    assert_includes s.categories, @a11
    assert_equal 3, s.categories.count
  end
  
  test "shop should be member of parent categories even if explicit removed" do
    build_categories
    
    s = Shop.make
    
    s.categories << @a11
    s.categories.delete @a
    s.save!
    
    assert_includes s.categories, @a
    assert_includes s.categories, @a1
    assert_includes s.categories, @a11
    assert_equal 3, s.categories.count
  end
  
  test "shop description should be translated" do
    shop = Shop.make :description => 'Description'
    shop.save_translation :es, :description => 'Descripcion'
    
    assert_equal "Description", Shop.find_by_id(shop.id).description
    assert_equal "Descripcion", Shop.translated(:es).find(shop.id).description
  end
  
  test "new shop description must be marked as pending" do
    shop = Shop.make :description => 'Description'
    
    assert_equal 1, Shop.translation_pending(:es).count
    assert_equal shop.id, Shop.translation_pending(:es).first.id
  end
  
  test "translation for description should be marked as pending when updated" do
    shop = Shop.make
    shop.save_translation 'es', :description => 'Descripcion'

    assert_equal "Descripcion", Shop.translated(:es).find_by_id(shop.id).description
    assert_equal 0, Shop.translation_pending(:es).count
    
    shop.description = 'New description'
    shop.save!

    assert_equal "New description", Shop.translated(:es).find_by_id(shop.id).description
    assert_equal 1, Shop.translation_pending(:es).count
  end
  
  test "translation for description should not be marked as pending when unchanged" do
    shop = Shop.make
    shop.save_translation 'es', :description => 'Descripcion'

    assert_equal "Descripcion", Shop.translated(:es).find_by_id(shop.id).description
    assert_equal 0, Shop.translation_pending(:es).count
    
    shop.url = 'http://example.com.ar'
    shop.save!

    assert_equal "Descripcion", Shop.translated(:es).find_by_id(shop.id).description
    assert_equal 0, Shop.translation_pending(:es).count
  end
  
  test "should return shop translated fields" do
    assert_equal [:description], Shop.translated_fields[:translate]
    assert_equal [:name, :description], Shop.translated_fields[:index]
    assert_equal [:description, :name], Shop.translated_fields[:all]
  end
end
