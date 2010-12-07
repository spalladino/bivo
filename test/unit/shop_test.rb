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
    shop = Shop.make
    
    Translation.create! :translated_type => Shop.name, :translated_id => shop.id, :translated_field => 'description', :language => 'es', :value => "Descripcion", :pending => false

    assert_equal "Descripcion", Shop.translated('es').find_by_id(shop.id).description
  end
  
  test "create translation for shop description" do
    shop = Shop.make
    shop.set_translation 'es', :description, 'Descripcion'
    assert_equal "Descripcion", Shop.translated('es').find_by_id(shop.id).description
  end
  
  test "translation for description should be marked as pending when updated" do
    shop = Shop.make
    shop.set_translation 'es', :description, 'Descripcion'
    assert_equal "Descripcion", Shop.translated('es').find_by_id(shop.id).description
    
    shop.description = 'New description'
    shop.save!
    assert_equal "New description", Shop.translated('es').find_by_id(shop.id).description
  end
  
  test "translation for description should not be marked as pending when unchanged" do
    shop = Shop.make
    shop.set_translation 'es', :description, 'Descripcion'
    assert_equal "Descripcion", Shop.translated('es').find_by_id(shop.id).description
    
    shop.name = 'New name'
    shop.save!
    assert_equal "Descripcion", Shop.translated('es').find_by_id(shop.id).description
  end
end
