module CommentsHelper

  def reply_comment_button(id,entity)
    if rules(entity).can_add?(current_user)
      return raw("<li><a href=\"#\" name=\"reply_or_add_button\" onclick=\"showComments(this, #{id});return false;\">#{_("Reply")}</a></li><li class=\"rpPipe\">|</li>")
    end
  end

  def edit_comment_button(id,entity,body)
    if rules(entity).can_edit?(current_user,entity)
      return raw("<li><a href=\"#\" id=\"edit_button_#{id}\" onclick=\"editComment(#{id},\'#{nl2br(body)}\');return false;\">#{_("Edit")} </a></li><li class=\"rpPipe\">|</li>")
    end
  end

  def delete_comment_button(id,entity)
    comment = Comment.find(id)
    if rules(entity).can_delete?(current_user,entity,comment)
     form_tag({:action => "destroy",:controller => "comments", :id => id, :entity_id => entity.id, :class => entity.class}, {:remote=>true}) do
        link_to _("Delete"), "#", :disable_with => _('Deleting...'), :class => "submit_form", :confirm => "Are you sure you want to delete this comment?"
      end
    end
  end


  def add_comment_button(entity)
    if rules(entity).can_add?(current_user)
      return raw("<a href = \"#\" class = \"leav\" name = \"reply_or_add_button\" onclick=\"showComments(this, null);return false;\">#{_("Add Comment")}</a>")
    end
  end

  def save_comment_button(id)
    comment = Comment.find(id)
    link_to _("Save"), "#",:disable_with => _('Submitting...'),:id => "save_button_#{comment.id}",:class => "submit_form"
  end

  def submit_comment_button
    link_to _("Submit"), "#",:disable_with => _('Submitting...'),:class => "submit_form"
  end

  def cancel_save_button(id)
     return raw("<a href = \"#\" id =\"cancel_button_#{id}\" onclick=\"cancelEdit(#{id});return false\">#{_("Cancel")}</a>")
  end

  def cancel_add_button
     return raw("<a href = \"#\" name =\"cancel_button\" class=\"nodisplay\" onclick=\"cancelAdd(this);return false;\">#{_("Cancel")}</a>")
  end

  def rules(entity)
    eval("#{entity.class}::CommentRules")
  end

  def comments_roots_by_date(entity)
    return Comment.where(:commentable_id => entity.id, :commentable_type => entity.class.name,:parent_id => nil, :approved => true).order('created_at ASC')
  end

  def owner_of(comment)
    if comment.user.nil?
      return "-"
    elsif comment.user.is_admin_user
      return "Admin"
    elsif !comment.user.nickname.blank?
      return comment.user.nickname
    else
      return comment.user.name
    end
  end

  def children(comment)
    return Comment.where(:parent_id => comment.id,:approved => true).order('created_at ASC')
  end

  def approve_comment_button(id,entity)
    if rules(entity).can_approve?(current_user,entity,Comment.find(id))
      link_to(_("Approve"),{:action => "approve",:controller => "comments", :id => id, :entity_id => entity.id, :class => entity.class}, :remote => true, :method => "post")
    else
      ""
    end
  end
end

