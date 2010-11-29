class Mailer < ActionMailer::Base
  default :from => "admin@bivo.com"

  # If some cause is followed, the charity who created it should receive an email.
  def cause_being_followed(user_data)
    mail :to => charity.email, :subject => "#{follower.name} is following cause #{cause.name}"
  end
  # If a cause complete its funds needed, the followers should receive an email.
  def funds_completed(user_data)
    mail :to => follower.email, :subject => "cause #{cause.name} has completed collecting funds"
  end
  # If a cause change its status, followers should receive an email.
  def cause_status_changed(user_data)
    mail :to => follower.email, :subject => "cause status changed"
  end
  # If a new is created, the followers of the cause associated to the new should receive an email.
  def new_created(user_data)
    mail :to => follower.mail, :subject => "news about the cause"
  end
  # If a cause is commented, the followers of the cause should receive an email 
  # (filter comments so that only check moderated because there may be comments without auto approve).
  def cause_commented(user_data)
    mail :to => follower.mail
  end
end
