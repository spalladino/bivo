require 'test_helper'

class GalleryTest < ActiveSupport::TestCase

  test "create gallery for entity" do
    c = Cause.make
    
    assert_difference 'Gallery.count' do
      g = Gallery.for_entity c
      
      assert_equal c.class.name, g.entity_type
      assert_equal c.id, g.entity_id
    end
    
    assert_no_difference 'Gallery.count' do
      Gallery.for_entity c
    end
    
  end
end
