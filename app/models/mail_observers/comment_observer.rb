# Observer for comments.
class CommentObserver < ActiveRecord::Observer

  def after_create(comment)
    @comment = comment
    
    if (comment.commentable_type.to_sym == :Cause)
      enqueue_cause_comment   
    elsif (comment.commentable_type.to_sym == :Charity || comment.commentable_type.to_sym == :User)
      enqueue_charity_comment
    end
  end

  private

  def enqueue_cause_comment
    Follow.where('cause_id = ? AND user_id != ?', @comment.commentable_id, @comment.user_id).each do |follow|
      PendingMail.create({
        :method => "cause_commented_for_follower",
        :data => Marshal.dump({
          :comment_id  => @comment.id,
          :cause_id    => @comment.commentable_id, 
          :follower_id => follow.user_id
        })
      })
    end

    cause = Cause.find(@comment.commentable_id)

    PendingMail.create({
      :method => "cause_commented_for_charity",
      :data => Marshal.dump({
        :comment_id  => @comment.id,
        :cause_id    => @comment.commentable_id,
        :charity_id => cause.charity.id
      })
    })
  end

  def enqueue_charity_comment
    # enqueuing an email for each follower of the charity about the comment
    CharityFollow.where('charity_id = ? AND user_id != ?', @comment.commentable_id, @comment.user_id).each do |follow|
      PendingMail.create({
        :method => "charity_commented_for_follower",
        :data => Marshal.dump({
          :comment_id  => @comment.id,
          :charity_id  => @comment.commentable_id,
          :follower_id => follow.user_id
        })
      })
    end

    PendingMail.create({
      :method => "charity_commented_for_charity",
      :data => Marshal.dump({
        :comment_id  => @comment.id,
        :charity_id  => @comment.commentable_id
      })
    }) unless @comment.user_id == @comment.commentable_id
  end
end
