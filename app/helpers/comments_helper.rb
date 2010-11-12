module CommentsHelper

  def reply_comment_button(id)
    return raw("<input type=\"button\" value=\"#{_("Reply")}\" onclick=\"showComments();reply(#{id})\"/>")
  end

  def edit_comment_button(id)
    return raw("<input type=\"button\" id =\"edit_button_#{id}\" value=\"#{_("Edit")}\" onclick=\"editComment(#{id})\"/>")
  end

  def delete_comment_button(id)
    return button_to(_("Delete"),{:action => "destroy",:controller => "comments", :id => id},:remote => true, :method => "post")
  end

  def add_comment_button
    return raw("<input type=\"button\" value=\"#{_("Add Comment")}\" onclick=\"showComments()\"/>")
  end



  def save_comment_button(id)
    return raw("<input type=\"button\" id =\"save_button_#{id}\" style=\"display:none\" value=\"#{_("Save")}\" onclick=\"saveEdit(#{id})\"/>")
  end

  def cancel_save_button(id)
     return raw("<input type=\"button\" id =\"cancel_button_#{id}\" style=\"display:none\" value=\"#{_("Cancel")}\" onclick=\"cancelEdit(#{id})\"/>")
  end

   def cancel_add_button
     return raw("<input type=\"button\" id =\"cancel_button\" style=\"display:none\" value=\"#{_("Cancel")}\" onclick=\"cancelAdd()\"/>")
  end


end

