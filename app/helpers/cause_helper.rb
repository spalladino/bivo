module CauseHelper

  def cause_funds_percentage_completed(cause)
    number_to_percentage cause.funds_raised/cause.funds_needed*100, :precision => 0
  end

  def cause_funds_completed(cause)
    "#{cause.funds_raised} (#{cause_funds_percentage_completed(cause)} #{_('complete')})"
  end

  def cause_voted(cause)
    return current_user && !Vote.find_by_cause_id_and_user_id(cause.id,current_user.id)
  end

  def view_cause_button(cause)
    return link_to _("View"), cause_path(cause.id)
  end

  # Displayed when the cause is in “voting” mode or when the user did not vote for the cause.
  # Users have to be logged in to vote. A cause can only be voted once.
  def vote_button(cause)
    visible = true
    disabled = nil

    if current_user.nil?
      visible = false
    elsif current_user.nil? and cause.can_vote?
      label = _("Login to vote")
      disabled = true
    else
      vote = Vote.new(:cause_id => cause.id ,:user_id => current_user.id)
      if vote.valid?
        label = _("Vote")
      else
        errors = vote.errors[:cause_id]
        label = errors
        disabled = true
        visible = vote.already_exists
      end
    end

   return content_tag :div,
      button_to(label, { :action => "vote", :id => cause.id },
        :remote => true,
        :disabled => disabled ,
        :onclick => '$(this).val("Submitting...");$(this).attr("disabled","true");return true;'),
      :class => (if not visible then 'hidden' end),
      :id => "vote_btn_#{cause.id}"
  end

  # *Follow* is displayed when the user is not following the cause, otherwise *Unfollow* is displayed.
  # If the user is logged off, redirects to the Login page.
  # When a cause is being followed the user gets e-mail alerts when the status of the cause changes.
  def follow_button(cause)
    if current_user.nil?
        label = _("Login to follow")
        disabled = true
    else
      follow = Follow.find_by_cause_id_and_user_id(cause.id, current_user.id)
      label = if follow then _("Unfollow") else _("Follow") end
      action = if follow then "unfollow" else "follow" end
    end

    return content_tag :div,
      button_to(label, { :action => action, :id => cause.id },
        :remote => true,
        :disabled => disabled ,
        :onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;'),
      :id => "follow_btn"

  end

  # *Deactivate* button: Deactivates the current cause,
  # *Activate* button: Displayed only when the cause is deactivated.
  def active_deactive_button(cause)
    if current_user && current_user.is_admin_user
      label = if cause.status_inactive? then _("Activate") else _("Deactivate") end
      action = if cause.status_inactive? then "activate" else "deactivate" end
      return content_tag :div, button_to(label, { :action => action, :id => cause.id },:remote => true,:onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;',:id => "submit_active_btn")
    end
  end


  # Uses the Like functionality of Facebook.
  def facebook_like
    content_tag :iframe, nil, :src => "http://www.facebook.com/plugins/like.php?href=#{CGI::escape(request.url)}&layout=standard&show_faces=true&width=450&action=like&font=arial&colorscheme=light&height=80", :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like
  end

  def mark_as_paid_button(cause)
    if current_user &&  current_user.is_admin_user
      if cause.can_mark_as_paid?
	      return content_tag :div, button_to("Mark as paid", { :action => "mark_paid", :id => cause.id })
      end
    end
  end

  def mark_as_unpaid_button(cause)
    if current_user && current_user.is_admin_user
      return content_tag :div, button_to("Mark as unpaid", { :action => "mark_unpaid", :id => cause.id })
    end
  end

  def vote_counter(cause)
    content_tag :span, cause.votes_count, :id => "vote_counter_#{cause.id}"
  end

  # Displays info on the cause depending on its status
  # * In “voting” mode: Displays the number of votes.
  # * In “raising funds” mode: Displays the funds raised and the fundraising progress percentage.
  # * In “completed” mode: Displays the funds raised.
  def progress_box(cause)
    if cause.status == :active
      return vote_counter cause
    elsif cause.status = :raising_funds
      return content_tag :span, cause_funds_completed(cause)
    elsif cause.status = :completed
      return content_tag :span, cause.founds_raised
    end
  end

  # Button redirecting to cause edition page
  # * Admin: Redirects to the “Cause Add/Edit” page. 
  # * Owner: Redirects to the “Cause Add/Edit” page. Causes with a “completed” status cannot be edited by the charity.
  def edit_button(cause)
    if current_user && (current_user.is_admin_user ||  (current_user.is_charity_user && cause.charity.id == current_user.id && cause.can_edit?))
      return content_tag :div, link_to("Edit", :controller => "causes", :action => "edit", :id => cause.id)
    end
  end


  # Redirects to the cause page. Charity. (Owner)
  def cause_link(cause)
    return content_tag :div,link_to(cause.name,cause_path(cause.id))
  end

  # Deletes cause
  # * Charity owner: Deletes the cause only if the status is “pending approval” or “voting”.
  # * Admin: Deletes the current cause. If the cause has a history of raised funds the deletion is logical.
  def delete_button(cause)
    if current_user && (current_user.is_admin_user || (current_user.is_charity_user && cause.charity.id == current_user.id && cause.can_delete?))
      return content_tag :div, button_to("Delete", cause_path(cause.id), :method => :delete, :confirm => "Are you sure?")
    end
  end



end

