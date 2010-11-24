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
    vi = VideoItem.new
    vi.video_url = params[:video_url]
    vi.gallery_id = params[:gallery_id]
    if vi.save
      ajax_flash[:notice] = _("Video submitted")
    else
      ajax_flash[:notice] = _("Error, invalid video url")
    end
    redirect_to request.referer
  end

 def add_photo
    pi = PhotoItem.new
    pi.attributes = params[:photo_item]
    if pi.save
      ajax_flash[:notice] = _("Photo submitted")
    else
      ajax_flash[:notice] = _("Error, try again")
    end
    redirect_to request.referer
  end

  def destroy_gallery_item
    item = GalleryItem.find(params[:id])
    @relative_ord = item.relative_order
    item.destroy
  end


end

