module CharitiesHelper

  # *Follow* is displayed when the user is not following the charity, otherwise *Unfollow* is displayed.
  # If the user is logged off, redirects to the Login page.
  # When a charity is being followed the user gets e-mail alerts when the status of the charity changes.
  def follow_button(charity)
    if current_user.nil?
        label = _("Login to follow")
        disabled = true
    else
      follow = CharityFollow.find_by_charity_id_and_user_id(charity.id, current_user.id)
      label = if follow then _("Unfollow") else _("Follow") end
      action = if follow then "unfollow" else "follow" end
    end

    return content_tag :div,
      button_to(label, { :action => action, :id => charity.id },
        :remote => true,
        :disabled => disabled ,
        :onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;'),
      :id => "follow_btn"

  end

  # Admin only action to change charity status
  # * Deactivate button:  All children causes are deactivated as well.
  # * Activate button: Displayed only when the charity is deactivated.
  def active_deactive_button(charity)
    if current_user && current_user.is_admin_user
      label = if charity.status_inactive? then _("Activate") else _("Deactivate") end
      action = if charity.status_inactive? then "activate" else "deactivate" end
      return content_tag :div, button_to(label, { :action => action, :id => charity.id },:remote => true,:onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;',:id => "submit_active_btn")
    end
  end


  # Uses the Like functionality of Facebook.
  def facebook_like
    content_tag :iframe, nil, :src => "http://www.facebook.com/plugins/like.php?href=#{CGI::escape(request.url)}&layout=standard&show_faces=true&width=450&action=like&font=arial&colorscheme=light&height=80", :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like
  end

  # Deletes the current charity. If the charity has a history of raised funds the deletion is logical. 
  # Admin only action.
  def delete_button(charity)
    if current_user && (current_user.is_admin_user)
      return content_tag :div, button_to("Delete", charity_path(charity.id), :method => :delete, :confirm => "Are you sure?")
    end
  end

  # Redirects to the “Add Cause” page.
  def add_cause_button(charity)
    if current_user && (current_user.is_admin_user ||  (current_user.is_charity_user && cause.charity.id == current_user.id))
      return content_tag :div, link_to("Add", :controller => "causes", :action => "new", :id => charity.id)
    end
  end


end

