# Observer for follows. It sends mails when a charity is being followed.
class CharityFollowObserver < ActiveRecord::Observer
  def after_save(charity_follow)
    PendingMail.create({
      :method => "charity_being_followed",
      :data => Marshal.dump({
        :follower_id => charity_follow.user_id,
        :charity_id  => charity_follow.charity_id
      })
    })
  end
end
