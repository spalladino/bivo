module ShopsHelper

  # *Deactivate* button: Deactivates the current shop,
  # *Activate* button: Displayed only when the shop is deactivated.
  def active_deactive_shop_button(shop)
    if current_user && current_user.is_admin_user
      label = if shop.active? then _("Deactivate") else _("Activate") end
      action = if shop.active? then "deactivate" else "activate" end
      return content_tag :div, button_to(label,
        { :action => action, :id => shop.id },
        :remote => true,
        :onclick => 'disableAndContinue(this,"Submitting..")',
        :id => "submit_active_btn"
      )
    end
  end


  def edit_shop_button(shop)
    if current_user && current_user.is_admin_user
      return content_tag :div, link_to(_("Edit"), :controller => "shops", :action => "edit", :id => shop.id)
    end
  end


  def delete_shop_button(shop)
    if current_user && current_user.is_admin_user
      return content_tag :div, button_to(_("Delete"), shop_path(shop.id), :method => :delete, :confirm => "Are you sure?")
    end
  end
  
  def inactive_shop_notification(shop)
    unless @shop.active?
      return content_tag :div, _("This shop is inactive and won't appear to users")
    end
  end
  





end

