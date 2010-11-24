class GalleriesController < ApplicationController

  def edit_view
    gallery = Gallery.find_by_entity_id(params[:entity_id])
    @gallery_id = gallery.id
    @gallery_items = GalleryItem.where('gallery_id = ?',gallery.id).order('relative_order')
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

  def video_preview
    @video = GalleryItem.find(params[:id])
  end

  def add_video
    VideoItem.create!(:video_url => params[:video_url], :gallery_id => params[:gallery_id])
    redirect_to request.referer
  end

 def add_photo
    pi = PhotoItem.new
    pi.attributes = params[:photo_item]
    pi.save!
    redirect_to request.referer
  end

  def destroy_gallery_item
    GalleryItem.find(params[:id]).destroy
  end


end

