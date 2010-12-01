# Observer for follows. It sends mails when a cause is being followed.
class FollowObserver < ActiveRecord::Observer
  def after_create(follow)
    PendingMail.create({
      :method => "cause_being_followed",
      :data => Marshal.dump({
        :follower_id => follow.user_id,
        :cause_id    => follow.cause_id,
      })
    })
  end
end
# Observer for follows. It sends mails when a charity is being followed.
class CharityFollowObserver < ActiveRecord::Observer
  def after_create(charity_follow)
    PendingMail.create({
      :method => "charity_being_followed",
      :data => Marshal.dump({
        :follower_id => charity_follow.user_id,
        :charity_id  => charity_follow.charity_id
      })
    })
  end
end
# Observer for causes. It sends mails when a cause change its status (special case if the new status is completed).
class CauseObserver < ActiveRecord::Observer
  def status_change(cause)
    @cause = cause

    @follows = Follow.where(:cause_id => @cause.id).map(&:user_id) | 
               CharityFollow.where(:charity_id => @cause.charity_id).map(&:user_id)

    if (cause.status.to_sym == :completed)
      enqueue_cause_completed
    else
      @follows.each do |user_id|
        PendingMail.create({
          :method => "cause_status_changed_for_follower",
          :data => Marshal.dump({
            :cause_id  => @cause.id,
            :follower_id => user_id
          })
        })
      end

      PendingMail.create({
        :method => "cause_status_changed_for_charity",
        :data => Marshal.dump({
          :cause_id  => @cause.id,
          :charity_id => @cause.charity_id
        })
      })
    end
  end

  private

  def enqueue_cause_completed
    @follows.each do |user_id|
      PendingMail.create({
        :method => "funds_completed_for_follower",
        :data => Marshal.dump({
          :cause_id  => @cause.id,
          :follower_id => user_id
        })
      })
    end

    PendingMail.create({
      :method => "funds_completed_for_charity",
      :data => Marshal.dump({
        :cause_id  => @cause.id,
        :charity_id => @cause.charity_id
      })
    })
  end
end
# Observer for comments.
class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    @comment = comment

    enqueue_cause_comment   if (comment.commentable_type.to_sym == :Cause)
    enqueue_charity_comment if (comment.commentable_type.to_sym == :Charity)
  end

  private

  def enqueue_cause_comment
    Follow.where(:cause_id => @comment.commentable_id).each do |follow|
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
    Follow.where(:cause_id => @comment.commentable_id).each do |follow|
      PendingMail.create({
        :method => "charity_commented_for_follower",
        :data => Marshal.dump({
          :comment_id  => @comment.id,
          :charity_id  => @comment.commentable_id,
          :follower_id => follow.user_id
        })
      })
    end

    cause = Cause.find(@comment.commentable_id)

    PendingMail.create({
      :method => "charity_commented_for_charity",
      :data => Marshal.dump({
        :comment_id  => @comment.id,
        :charity_id  => @comment.commentable_id
      })
    })
  end
end
# Observer for news.
class NewsObserver < ActiveRecord::Observer
  def after_create(news)
    @news = news

    enqueue_charity_news if (news.commentable_type.to_sym == :Charity)
    enqueue_cause_news   if (news.commentable_type.to_sym == :Cause)
  end

  private

  def enqueue_charity_news
    CharityFollow.where(:charity_id => @news.commentable_id).each do |follow|
      PendingMail.create({
        :method => "news_created_to_charity",
        :data => Marshal.dump({
          :news_id  => @news.id,
          :charity_id    => @comment.commentable_id, 
          :follower_id => follow.user_id
        })
      })
    end
  end

  def enqueue_cause_news
    Follow.where(:cause_id => @news.commentable_id).each do |follow|
      PendingMail.create({
        :method => "news_created_to_cause",
        :data => Marshal.dump({
          :news_id  => @news.id,
          :cause_id    => @comment.commentable_id,
          :follower_id => follow.user_id
        })
      })
    end
  end
end
