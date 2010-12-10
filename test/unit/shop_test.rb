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
  
  test "should search in name" do
    shop = Shop.make :name => 'book'
    assert_equal [shop.id], Shop.search('books').map(&:id)
  end
  
  test "should search in description" do
    shop = Shop.make :description => 'book'
    assert_equal [shop.id], Shop.search('books').map(&:id)
  end
  
  test "should search in translated fields" do
    shop = Shop.make :description => 'book'
    shop.save_translation 'es', :description => 'libro'

    assert_equal [], Shop.search('libro').map(&:id)
    assert_equal [shop.id], Shop.search_translated('libro', :es).map(&:id)
  end
  
  test "should search in untranslated fields if translation is pending" do
    shop = Shop.make :name => 'book'
    shop.save_translation 'es', :name => 'libro'
    shop.name = 'car'
    shop.save!

    assert_equal [], Shop.search_translated('libros', :es).map(&:id)
    assert_equal [shop.id], Shop.search_translated('car', :es).map(&:id)
  end

  test "status test methods when active" do
    s = Shop.make_unsaved :status => :active
    assert s.active?
    assert s.status_active?
    assert !s.inactive?
    assert !s.status_inactive?    
  end

  test "status test methods when inactive" do
    s = Shop.make_unsaved :status => :inactive
    assert s.inactive?
    assert s.status_inactive?
    assert !s.active?
    assert !s.status_active?    
  end

end
