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
end
