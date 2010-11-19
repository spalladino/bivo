class GalleriesController < ApplicationController

  def edit_view
    @entity = Charity.first
  end

  def move_up

    gallery_item = GalleryItem.find(params[:id])
    @old_position = gallery_item.relative_order.to_s
    gallery_item.move_up
    @new_position = gallery_item.relative_order.to_s
  end

  def move_down
    gallery_item = GalleryItem.find(params[:id])
    @old_position = gallery_item.relative_order.to_s
    gallery_item.move_down
    @new_position = gallery_item.relative_order.to_s
  end
end

