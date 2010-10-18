module CauseHelper

  def category_filter_url(category)
    query = CGI.parse(request.query_string).symbolize_keys
    query.each {|k,v| query[k] = v.first}
    query[:category] = category.id
    url_for({:action => 'index', :controller => 'causes'}.merge(query))
  end

  def follow_button(cause)
    
    if current_user.nil?
        label = _("Follow (you must login first)")
        route = "#{cause.id}/follow"
    else
      follow = Follow.find_by_cause_id_and_user_id(cause.id, current_user.id)
      label = if follow then _("Unfollow") else _("Follow") end
      route = if follow then "#{cause.id}/unfollow" else "#{cause.id}/follow" end
    end
    
    return content_tag :div, button_to(label, route, 
      :remote => true,
      :method => 'follow',
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
    
    return content_tag :div, button_to(label, "#{cause.id}/vote", 
      :remote => true,
      :method => 'vote',
      :id => "submit_vote_btn",
      :disabled => disabled ,
      :onclick => '$(this).val("Submitting...");$(this).attr("disabled", "true");return true;'),
      :class => (if not visible then 'hidden' end)
    
  end

end
