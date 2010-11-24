module GalleriesHelper

  def move_up_button(id)
    return button_to(_("Move Up"),{:action => "move_up",:controller => "galleries", :id => id}, :remote => true, :method => "post")
  end

  def move_down_button(id)
    return button_to(_("Move Down"),{:action => "move_down",:controller => "galleries", :id => id}, :remote => true, :method => "post")
  end

  def delete_item_button(id)
    return button_to(_("Destroy"),{:action => "destroy_gallery_item",:controller => "galleries", :id => id}, :remote => true, :method => "post")
  end

end

