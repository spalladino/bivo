module GalleriesHelper

  def move_up_button(id)
    return button_to(_("Move Up"),{:action => "move_up",:controller => "galleries", :id => id}, :remote => true, :method => "post")
  end

  def move_down_button(id)
    return button_to(_("Move Down"),{:action => "move_down",:controller => "galleries", :id => id}, :remote => true, :method => "post")
  end

  def delete_item_button(id)
    return button_to(_("Destroy"),{:action => "destroy_gallery_item",:controller => "galleries", :id => id}, :remote => true, :method => "post", :name => "delete_button_" + id.to_s)
  end

 def add_video_button()
   return raw("<input type=\"button\" id = \"add_video_button\" value=\"#{_("Add Video")}\" onclick=\"showVideoAdd(this);\"/>")
  end

 def add_photo_button()
   return raw("<input type=\"button\" id = \"add_photo_button\" value=\"#{_("Add Photo")}\" onclick=\"showPhotoAdd(this);\"/>")
  end
end

