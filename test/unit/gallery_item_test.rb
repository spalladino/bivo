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

  test 'moves up' do
    first = GalleryItem.make
    second = GalleryItem.make :gallery => first.gallery

    second.move_up

    first.reload
    second.reload

    assert_equal 2, first.relative_order
    assert_equal 1, second.relative_order
  end

  test 'moves up in same gallery' do
    first_other = GalleryItem.make

    test_moves_up
  end

  test 'moves up with three elements' do
    gallery = Gallery.make
    items = GalleryItem.make_many 3, :gallery => gallery

    items[2].move_up

    items.map! &:reload

    assert_equal 1, items[0].relative_order
    assert_equal 3, items[1].relative_order
    assert_equal 2, items[2].relative_order
  end

  test 'moves up with four elements' do
    gallery = Gallery.make
    items = GalleryItem.make_many 4, :gallery => gallery

    items[2].move_up
    items.map! &:reload

    items[3].move_up
    items.map! &:reload

    assert_equal 1, items[0].relative_order
    assert_equal 4, items[1].relative_order
    assert_equal 2, items[2].relative_order
    assert_equal 3, items[3].relative_order
  end

  test 'doesnt move up' do
    first = GalleryItem.make
    first.move_up
    assert_equal 1, first.reload.relative_order
  end

  test 'moves down' do
    first = GalleryItem.make
    second = GalleryItem.make :gallery => first.gallery

    first.move_down

    first.reload
    second.reload

    assert_equal 2, first.relative_order
    assert_equal 1, second.relative_order
  end

end

