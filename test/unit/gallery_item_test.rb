require 'test_helper'

class GalleryItemTest < ActiveSupport::TestCase

  test "correct relative order in first create" do
    assert_equal 1, GalleryItem.make.relative_order
  end

  test 'correct relative order in second create' do
    first = GalleryItem.make
    second = GalleryItem.make :gallery => first.gallery
    assert_equal 2, second.relative_order
  end

  test 'correct relative order is one after max' do
    first = GalleryItem.make
    second = GalleryItem.make :gallery => first.gallery
    first.destroy
    assert_equal 3, GalleryItem.make(:gallery => second.gallery).relative_order
  end


  test 'correct relative order is one after max in corresponding entity' do
    gal1 = Gallery.make
    itemChar1 = GalleryItem.make(:gallery => gal1)

    gal2 = Gallery.make
    item1Char2 = GalleryItem.make(:gallery => gal2)
    item2Char2 = GalleryItem.make(:gallery => gal2)

    assert_equal 1, itemChar1.relative_order
    assert_equal 2, item2Char2.relative_order

  end


end

