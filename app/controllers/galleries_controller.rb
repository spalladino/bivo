class GalleriesController < ApplicationController

  def edit_view
    @id = params[:entity_id]
    @gallery_items = GalleryItem.where('gallery_id = ?',Gallery.find_by_entity_id(params[:entity_id])).order('relative_order')
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

