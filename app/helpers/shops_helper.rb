module ShopsHelper

  # *Deactivate* button: Deactivates the current shop,
  # *Activate* button: Displayed only when the shop is deactivated.
  def active_deactive_shop_button(shop)
    if current_user && current_user.is_admin_user
      label = if shop.active? then _("Deactivate") else _("Activate") end
      action = if shop.active? then "deactivate" else "activate" end
      return gray_button_to(label,
        { :action => action, :id => shop.id },
        :remote => true,
        :onclick => 'disableAndContinue(this,"Submitting..")',
        :id => "submit_active_btn"
      )
    end
  end

  def edit_shop_button(shop)
    if current_user && current_user.is_admin_user
      return gray_link_to(_("Edit"), :controller => "shops", :action => "edit", :id => shop.id)
    end
  end

  def delete_shop_button(shop)
    if current_user && current_user.is_admin_user
      return gray_button_to(_("Delete"), shop_path(shop.id), :method => :delete, :confirm => "Are you sure?") 
    end
  end
  
  def inactive_shop_notification(shop)
    unless @shop.active?
      return content_tag :div, _("This shop is inactive and won't appear to users")
    end
  end
  
  def to_absolute_url(shop_website, default_protocol='http')
    if shop_website =~ /^([^:])+:\/\// 
      URI.escape(shop_website) 
    else 
      "#{default_protocol}://#{URI.escape(shop_website)}"
    end
  end

  def shop_at_link(shop, html_opts={})
    url = if shop.redirection_purchase_button?
      to_absolute_url(shop.affiliate_code)
    else
      shop_home_path(shop.short_url)
    end
    link_to _("Shop at %s") % shop.display_name, url, html_opts
  end
  
  def comission_value_text(shop)
    value_s = shop.comission_value.to_s
    shop.comission_kind_percentage? ? "#{value_s}%" : value_s
  end

end

