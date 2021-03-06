module CharitiesHelper

  # *Follow* is displayed when the user is not following the charity, otherwise *Unfollow* is displayed.
  # If the user is logged off, redirects to the Login page.
  # When a charity is being followed the user gets e-mail alerts when the status of the charity changes.
  def follow_charity_button(charity, opts={})
    if current_user.nil?
        label = _("Login to follow")
        disabled = true
    else
      follow = CharityFollow.find_by_charity_id_and_user_id(charity.id, current_user.id)
      label = if follow then _("Unfollow") else _("Follow") end
      action = if follow then "unfollow" else "follow" end
    end

    return content_tag :div,
    button_to(label,
        {:action => action, :id => charity.id },
        {
        :remote => true,
        :disabled => disabled ,
        :onclick => 'disableAndContinue(this,"Submitting...")',
        :id => "follow_charity_btn"
        }.merge(opts)
      ),
      :id => "follow_charity_button"
  end

 # Deletes the current charity. If the charity has a history of raised funds the deletion is logical.
  # Admin only action.
  def delete_charity_button(charity)
    if current_user && (current_user.is_admin_user)
      return orange_link_to _("Delete"), { :action => "destroy", :controller => "registrations", :id => charity.id }, :confirm => "are you sure you want to delete the user?", :method => :delete
    end
  end

  # Renders a control with stars that indicate charity rating
  def rating_stars(charity, html_opts={})
    return (content_tag :ul, (0..4).map { |idx|
      img = (charity.rating || 0).to_i >= idx ? 'star.png' : 'starHo.png'
      content_tag :li, image_tag(img, :width => 15, :height => 15), {}, false
    }.join("\n"), {:class => 'star'}.merge(html_opts), false).html_safe
  end

  # Redirects to the “Add Cause” page.
  def add_cause_button(charity)
    if current_user && (current_user.is_admin_user || (current_user.is_charity_user && charity.id == current_user.id))
      return content_tag :div, orange_link_to(_("Add Cause"), :controller => "causes", :action => "new", :charity_id => charity.id)
    end
  end


  def charity_comments_pending(charity)
    if current_user && charity.id == current_user.id && (charity.comments_to_approve_count > 0)
      return content_tag :div, orange_link_to(_("Approve comments (%s)") % charity.comments_to_approve_count, :controller => "charities", :action => "manage_comments", :id => charity.id)
    end
  end

  # TODO rename
  def comments_to_approve(charity)
    return Comment.where(:commentable_type => charity.class.name, :commentable_id => charity.id, :approved => false).order('created_at ASC')
  end

  def charity_big_avatar(charity)
    photo = charity.first_gallery_photo
    photo.try(:big_avatar_url) || '/images/missing-charities-big_avatar.png'
  end
end

