# Observer for follows. It sends mails when a cause is being followed.
class FollowObserver < ActiveRecord::Observer
  def after_create(follow)
    PendingMail.create({
      :method => "cause_being_followed",
      :data => Marshal.dump({
        :follower_id => follow.user_id,
        :cause_id    => follow.cause_id
      })
    })
  end
end
