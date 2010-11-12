module CommentsHelper

  def reply_comment_button(id,entity)
    if rules(entity).can_add?(current_user)
      return raw("<input type=\"button\" value=\"#{_("Reply")}\" onclick=\"showComments();reply(#{id})\"/>")
    end
  end

  def edit_comment_button(id,entity)
    if rules(entity).can_edit?(current_user,entity)
      return raw("<input type=\"button\" id =\"edit_button_#{id}\" value=\"#{_("Edit")}\" onclick=\"editComment(#{id})\"/>")

    end
  end

  def delete_comment_button(id,entity)
    if rules(entity).can_delete?(current_user,entity)
      return button_to(_("Delete"),{:action => "destroy",:controller => "comments", :id => id, :class => entity.class, :entity_id => entity.id }, :remote => true, :method => "post")
    end
  end

  def add_comment_button(entity)
    if rules(entity).can_add?(current_user)
      return raw("<input type=\"button\" value=\"#{_("Add Comment")}\" onclick=\"showComments()\"/>")
    end
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

  def rules(entity)
    eval("#{entity.class}::CommentRules")
  end

  def comments_ordered_by_date(entity)
      Comment.where(:commentable_id => entity.id, :commentable_type => entity.class.name).order('created_at ASC')
  end
end

