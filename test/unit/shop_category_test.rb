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
end
