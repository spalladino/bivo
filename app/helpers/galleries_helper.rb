module GalleriesHelper

  def move_before_button(id)
    return button_to(_("<"),{:action => "move_up",:controller => "galleries", :id => id}, :remote => true, :method => "post")
  end

  def move_after_button(id)
    return button_to(_(">"),{:action => "move_down",:controller => "galleries", :id => id}, :remote => true, :method => "post")
  end

  def delete_item_button(id)
    return button_to(_("x"),{:action => "remove_item",:controller => "galleries", :id => id}, :remote => true, :method => "post")
  end
  
end

