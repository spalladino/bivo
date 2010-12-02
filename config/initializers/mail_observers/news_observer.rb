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
