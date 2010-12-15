module CommentsHelper

  def reply_comment_button(id,entity)
    if rules(entity).can_add?(current_user)
      return raw("<input type=\"button\" name=\"reply_or_add_button\" value=\"#{_("Reply")}\" onclick=\"showComments(this, #{id})\"/>")
    end
  end

  def edit_comment_button(id,entity,body)
    if rules(entity).can_edit?(current_user,entity)
      return raw("<input type=\"button\" id =\"edit_button_#{id}\" value=\"#{_("Edit")}\" onclick=\"editComment(#{id},\'#{nl2br(body)}\')\"/>")

    end
  end

  def delete_comment_button(id,entity)
    if rules(entity).can_delete?(current_user,entity,Comment.find(id))
      return button_to(_("Delete"),{:action => "destroy",:controller => "comments", :id => id, :entity_id => entity.id, :class => entity.class}, :remote => true, :method => "post")
    end
  end

  def add_comment_button(entity)
    if rules(entity).can_add?(current_user)
      return raw("<input type=\"button\" class = \"leav\" name = \"reply_or_add_button\" value=\"#{_("Add Comment")}\" onclick=\"showComments(this, null);\"/>")
    end
  end


  def save_comment_button(id)
    return raw("<input type=\"button\" id =\"save_button_#{id}\" class=\"nodisplay\" value=\"#{_("Save")}\" onclick=\"saveEdit(#{id})\"/>")
  end

  def cancel_save_button(id)
     return raw("<input type=\"button\" id =\"cancel_button_#{id}\" class=\"nodisplay\" value=\"#{_("Cancel")}\" onclick=\"cancelEdit(#{id})\"/>")
  end

   def cancel_add_button
     return raw("<input type=\"button\" name =\"cancel_button\" class=\"nodisplay\" value=\"#{_("Cancel")}\" onclick=\"cancelAdd(this)\"/>")
  end

  def rules(entity)
    eval("#{entity.class}::CommentRules")
  end

  def comments_roots_by_date(entity)
    return Comment.where(:commentable_id => entity.id, :commentable_type => entity.class.name,:parent_id => nil, :approved => true).order('created_at ASC')
  end

  def owner_of(comment)
    return (User.find(comment.user_id)).email
  end

  def children(comment)
    return Comment.where(:parent_id => comment.id,:approved => true).order('created_at ASC')
  end

  def approve_comment_button(id,entity)
    if rules(entity).can_approve?(current_user,entity,Comment.find(id))
    return button_to(_("Approve"),{:action => "approve",:controller => "comments", :id => id, :entity_id => entity.id, :class => entity.class}, :remote => true, :method => "post")
    end
  end
end

