module CauseHelper

  def cause_funds_percentage_completed(cause)
    number_to_percentage cause.funds_raised/cause.funds_needed*100, :precision => 0
  end

  def cause_voted(cause)
    return current_user && !!Vote.find_by_cause_id_and_user_id(cause.id, current_user.id)
  end

  def view_cause_button(cause, opts={})
   return orange_button(link_to(_("View"), cause_details_path(cause.url), {:class => 'buttonMid accBtnMi'}.merge(opts)))
  end

  # Displayed when the cause is in “voting” mode or when the user did not vote for the cause.
  # Users have to be logged in to vote. A cause can only be voted once.
  def vote_button(cause, small=false, opts={})
    visible = true
    disabled = nil

    if current_user.nil? && !cause.can_vote?
      return nil
    elsif current_user.nil? && cause.can_vote?
      label = _("Login to vote")
      disabled = true
    else
      vote = Vote.new(:cause_id => cause.id ,:user_id => current_user.id)
      if vote.valid?
        label = _("Vote")
      else
        errors = vote.errors[:cause_id]
        label = vote.already_exists ? _("Voted") : _("Vote")
        # label = errors # displaying the errors was ugly. just diplay Vote.
        disabled = true
        visible = vote.already_exists
      end
    end

    render :partial => 'cause_buttons', :locals => {
      :action => 'vote', 
      :label => label, 
      :id => cause.id, 
      :disabled => disabled, 
      :visible => visible,
      :button_id =>"vote_btn_" + cause.id.to_s,
      :small => small,
      :url_opts => {:small => small},
      :disable_with => _("Voting...")
    }

end



  # *Follow* is displayed when the user is not following the cause, otherwise *Unfollow* is displayed.
  # If the user is logged off, redirects to the Login page.
  # When a cause is being followed the user gets e-mail alerts when the status of the cause changes.
  def follow_cause_button(cause)
    if current_user.nil?
        label = _("Login to follow")
        disabled = true
    else
      follow = Follow.find_by_cause_id_and_user_id(cause.id, current_user.id)
      label = if follow then _("Unfollow") else _("Follow") end
      action = if follow then "unfollow" else "follow" end
      disable_with = if follow then _("Unfollowing...") else _("Following...") end
    end

    visible = true

    render :partial => 'cause_buttons',:locals => {
      :action => action, 
      :label => label, 
      :id => cause.id, 
      :disabled => disabled, 
      :visible => visible,
      :button_id =>"follow_cause_button",
      :disable_with => disable_with
    }

  end

  # *Deactivate* button: Deactivates the current cause,
  # *Activate* button: Displayed only when the cause is deactivated.
  def active_deactive_cause_button(cause)
    if current_user && current_user.is_admin_user
      label = if cause.status_inactive? then _("Activate") else _("Deactivate") end
      action = if cause.status_inactive? then "activate" else "deactivate" end
      return orange_button_to(label,
        {:action => action, :id => cause.id },
        :remote => true,
        :onclick => 'disableAndContinue(this,"Submitting...")',
        :id => "submit_active_btn"
      )
    end
  end



  def mark_as_paid_and_unpaid_button(cause)
    if current_user && current_user.is_admin_user && ([:completed, :paid].include? cause.status)
      label = if cause.status_completed? then _("Mark as Paid") else _("Mark as Unpaid") end
      action = if cause.status_completed? then "mark_paid" else "mark_unpaid" end
      return content_tag :div, button_to(label,
        {:action => action, :id => cause.id },
        :remote => true,
        :onclick => 'disableAndContinue(this,"Submitting...")',
        :id => "submit_active_btn"
      )
    end
  end

  def vote_counter(cause, opts={})
    content_tag :span, cause.votes_count, {:id => "vote_counter_#{cause.id}"}.merge(opts)
  end

  
  # Displays info on the cause depending on its status
  # * In “voting” mode: Displays the number of votes.
  # * In “raising funds” mode: Displays the funds raised and the fundraising progress percentage.
  # * In “completed” mode: Displays the funds raised.
  def progress_box(cause)
    if cause.status == :active
      return raw(_("Voting (%s votes).") % %(<span id="vote_counter_#{cause.id}">#{cause.votes_count}</span>))
    elsif cause.status == :raising_funds
      return raw(_("Raising Funds (%s completed).") % [cause_funds_percentage_completed(cause)])
    elsif cause.status == :completed || cause.status == :paid
      return raw(_("Completed (%s funds raised).") % [number_to_currency(cause.funds_raised,:precision => 0)])
    else
      return raw(cause.status.description)
    end
  end


  # Redirects to the cause page. Charity. (Owner)
  def cause_link(cause)
    return content_tag :div,link_to(cause.name,cause_details_path(cause.url))
  end


  # Button redirecting to cause edition page
  # * Admin: Redirects to the “Cause Add/Edit” page.
  # * Owner: Redirects to the “Cause Add/Edit” page. Causes with a “completed” status cannot be edited by the charity.
  def edit_cause_button(cause)
    if current_user && (current_user.is_admin_user ||  (current_user.is_charity_user && cause.charity.id == current_user.id && cause.can_edit?))
      return orange_link_to(_("Edit"), :controller => "causes", :action => "edit", :id => cause.id)
    end
  end


  # Deletes cause
  # * Charity owner: Deletes the cause only if the status is “pending approval” or “voting”.
  # * Admin: Deletes the current cause. If the cause has a history of raised funds the deletion is logical.
  def delete_cause_button(cause)
    if current_user && (current_user.is_admin_user || (current_user.is_charity_user && cause.charity.id == current_user.id && cause.can_delete?))
      return orange_button_to(_("Delete"), cause_path(cause.id), :method => :delete, :confirm => _("Are you sure?"))
    end
  end

  # TODO rename
  def comments_to_approve(cause)
    return Comment.where(:commentable_type => cause.class.name, :commentable_id => cause.id, :approved => false).order('created_at ASC')
  end
  
  def cause_big_avatar(cause)
    photo = cause.first_gallery_photo
    photo.try(:big_avatar_url) || '/images/missing-causes-big_avatar.png'
  end

  def cause_comments_pending(cause)
    if ((current_user) && (cause.charity.id == current_user.id) && 
       (cause.comments_to_approve_count > 0))
      content_tag :div, orange_link_to(_("Approve comments (%s)") % cause.comments_to_approve_count, :controller => "charities", :action => "manage_comments", :id => cause.charity.id)
    end
  end
end

