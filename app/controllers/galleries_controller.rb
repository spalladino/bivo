class GalleriesController < ApplicationController
  before_filter :load_entity
  before_filter :can_edit
  
  def edit
    @gallery = Gallery.for_entity @entity
  end

  def move_up
    gallery_item = GalleryItem.find(params[:id])
    @item_id = params[:id]
    gallery_item.move_up
    @preceding_item = gallery_item.gallery.items.where('relative_order < ?', gallery_item.relative_order).last
    render 'move_item'
  end

  def move_down
    gallery_item = GalleryItem.find(params[:id])
    @item_id = params[:id]
    gallery_item.move_down
    @preceding_item = gallery_item.gallery.items.where('relative_order < ?', gallery_item.relative_order).last
    render 'move_item'
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

  def remove_item
    item = GalleryItem.find(params[:id])
    @item_id = item.id
    item.destroy
  end

protected

  def load_entity
    @entity = params[:entity_type].constantize.find(params[:entity_id])
  end
  
  def can_edit
    if !eval("#{@entity.class}::GalleryRules").can_edit?(current_user, @entity)
      render :nothing => true, :status => :forbidden
    end
  end

end

