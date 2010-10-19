module CauseHelper

  def cause_funds_percentage_completed(cause)
    number_to_percentage cause.funds_raised/cause.funds_needed*100, :precision => 0
  end

  def cause_funds_completed(cause)
    "#{cause.funds_raised} (#{cause_funds_percentage_completed(cause)} #{_('complete')})"
  end

  def category_filter_url(category)
    query = CGI.parse(request.query_string).symbolize_keys
    query.each {|k,v| query[k] = v.first}
    query[:category] = category.id
    url_for({:action => 'index', :controller => 'causes'}.merge(query))
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

    return content_tag :div, 
      button_to(label, { :action => action, :id => cause.id },
        :remote => true,
        :onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;'),
      :id => "follow_btn"

  end

  def vote_counter(cause)
    content_tag :span, cause.votes_count, :id => "vote_counter_#{cause.id}" 
  end

  def vote_button(cause)
    visible = true
    disabled = nil
    
    if current_user.nil?
      label = _("Vote (you must login first)")
    else
      vote = Vote.new(:cause_id => cause.id ,:user_id => current_user.id)
      if vote.valid?
        label = _("Vote")
      else
        errors = vote.errors.on(:cause_id)
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

  def cause_voted(cause)
    return current_user && !Vote.find_by_cause_id_and_user_id(cause.id,current_user.id)
  end

  def view_cause_button(cause)
    return link_to _("View"), cause_path(cause.id)
  end

  def active_deactive_button(cause)
    if current_user.is_admin_user
      label = if cause.status_inactive? then _("Activate") else _("Deactivate") end
      action = if cause.status_inactive? then "activate" else "deactivate" end
      return content_tag :div, button_to(label, { :action => action, :id => cause.id },:remote => true,:onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;',:id => "submit_active_btn")
    end
  end

  def facebook_like
    content_tag :iframe, nil, :src => "http://www.facebook.com/plugins/like.php?href=#{CGI::escape(request.url)}&layout=standard&show_faces=true&width=450&action=like&font=arial&colorscheme=light&height=80", :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like
  end

  def mark_as_paid_button(cause)
    if cause.funds_raised >= cause.funds_needed
	    return content_tag :div, button_to("Mark as paid", { :action => "mark_paid", :id => cause.id })
    end
  end

  def delete_button(cause)
    return content_tag :div, button_to("Delete", cause_path(cause.id), :method => :delete, :confirm => "Are you sure?")
  end

end

