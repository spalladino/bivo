# Observer for causes. It enqueues mails when a cause change its status (special case if the new status is completed).
class CauseObserver < ActiveRecord::Observer
  # it is fired after a cause has changed its status and the new status is persisted.
  def status_change_persisted(cause)
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
