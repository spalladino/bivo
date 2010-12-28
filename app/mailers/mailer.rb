class Mailer < ActionMailer::Base
  default :from => Bivo::Application.config.action_mailer_default_from
  
  def cause_being_followed(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)
    @charity = @cause.charity

    mail :to => @charity.email, :subject => _("New Follower")
  end

  def charity_being_followed(mail_data)
    @follower = User.find(mail_data.follower_id)
    @charity = Charity.find(mail_data.charity_id)

    mail :to => @charity.email, :subject => _("New Follower")
  end

  def cause_status_changed_for_charity(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.charity_id)

    mail :to => @follower.email, :subject => _("Cause status changed")
  end

  def cause_status_changed_for_follower(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)

    mail :to => @follower.email, :subject => _("Cause status changed")
  end

  def cause_commented_for_charity(mail_data)
    @charity = User.find(mail_data.charity_id)
    @cause = Cause.find(mail_data.cause_id)
    @comment = Comment.find mail_data.comment_id

    mail :to => @charity.email, :subject => _("New comment in your cause")
  end

  def cause_commented_for_follower(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)
    @comment = Comment.find mail_data.comment_id

    mail :to => @follower.email, :subject => _("New comment for cause")
  end

  def charity_commented_for_follower(mail_data)
    @charity = Charity.find(mail_data.charity_id)
    @follower = User.find(mail_data.follower_id)
    @comment = Comment.find mail_data.comment_id
 
    mail :to => @follower.email, :subject => _("New comment to charity")
  end

  def charity_commented_for_charity(mail_data)
    @charity = Charity.find(mail_data.charity_id)
    @comment = Comment.find mail_data.comment_id
 
    mail :to => @charity.email, :subject => _("New comment in your page")
  end

  def funds_completed_for_charity(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @charity = User.find(mail_data.charity_id)

    mail :to => @charity.email, :subject => _("Cause completed")
  end

  def funds_completed_for_follower(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)

    mail :to => @follower.email, :subject => _("Cause completed")
  end

  def news_created_to_cause(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)
    @new = News.find(mail_data.news_id)

    mail :to => @follower.email, :subject => _("News about the cause")
  end

  def news_created_to_charity(mail_data)
    @charity = Charity.find(mail_data.charity_id)
    @follower = User.find(mail_data.follower_id)
    @new = News.find(mail_data.news_id)

    mail :to => @follower.email, :subject => _("News about the charity")
  end
end
