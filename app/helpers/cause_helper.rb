module CauseHelper

  def cause_category_filter_url(category)
    query = CGI.parse(request.query_string)
    query['category'] = category.id
  end

  def follow_button(cause)

    if current_user.nil?
        label = _("Follow (you must login first)")
        action = "follow"
    else
      follow = Follow.find_by_cause_id_and_user_id(cause.id, current_user.id)
      label = if follow then _("Unfollow") else _("Follow") end
      action = if follow then "unfollow" else "follow" end
    end

    return content_tag :div, button_to(label,  { :action => action, :id => cause.id },
      :remote => true,
      :id => "submit_follow_btn",
      :onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;')

  end


  def vote_button(cause)

    if current_user.nil?
      label = _("Vote (you must login first)")
      disabled = false
      visible = true
    else
      vote = Vote.new(:cause_id => cause.id ,:user_id => current_user.id)
      if vote.valid?
        label = _("Vote")
        disabled = false
        visible = true
      else
        errors = vote.errors.on(:cause_id)
        label = errors
        disabled = true
        visible = vote.already_exists
      end
    end

    return content_tag :div, button_to(label, { :action => "vote", :id => cause.id },
      :remote => true,
      :id => "submit_vote_btn",
      :disabled => disabled ,
      :onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;'),
      :class => (if not visible then 'hidden' end)

  end


  def active_deactive_button(cause)

    if current_user.is_admin_user
      label = if cause.status_inactive? then _("Activate") else _("Deactivate") end
      action = if cause.status_inactive? then "activate" else "deactivate" end
      return content_tag :div, button_to(label,  { :action => action, :id => cause.id },:remote => true,:onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;',:id => "submit_active_btn")
    end



  end


  def mark_as_paid_button(cause)
    if cause.funds_raised >= cause.funds_needed
	    return content_tag :div, button_to("Mark as paid", { :action => "mark_paidde", :id => cause.id })
    end
  end


  def delete_button(cause)
    return content_tag :div, button_to("Delete", { :action => "destroy", :id => cause.id },:confirm => "Are you sure?")
  end

end

