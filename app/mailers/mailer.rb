class Mailer < ActionMailer::Base
  default :from => Bivo::Application.config.action_mailer_default_from
  
  def cause_being_followed(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)
    @charity = @cause.charity

    set_locale @charity
    mail :to => @charity.email, :subject => _('The cause "') + @cause.name + _('" has a new Follower')
  end

  def charity_being_followed(mail_data)
    @follower = User.find(mail_data.follower_id)
    @charity = Charity.find(mail_data.charity_id)

    set_locale @charity
    mail :to => @charity.email, :subject => _('The charity "') + @charity.name + _('" has a new Follower')
  end

  def cause_status_changed_for_charity(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.charity_id)

    set_locale @follower
    mail :to => @follower.email, :subject => _('The cause "' ) + @cause.name + _('" from your charity has changed its status')
  end

  def cause_status_changed_for_follower(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)

    set_locale @follower
    mail :to => @follower.email, :subject => _("A cause you follow has changed its status")
  end

  def cause_commented_for_charity(mail_data)
    @charity = User.find(mail_data.charity_id)
    @cause = Cause.find(mail_data.cause_id)
    @comment = Comment.find mail_data.comment_id

    set_locale @charity
    mail :to => @charity.email, :subject => _('The cause "' ) + @cause.name + _('" from your charity has a new comment')
  end

  def cause_commented_for_follower(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)
    @comment = Comment.find mail_data.comment_id

    set_locale @follower
    mail :to => @follower.email, :subject => _('The cause "' ) + @cause.name + _('" has a new comment')
  end

  def charity_commented_for_follower(mail_data)
    @charity = Charity.find(mail_data.charity_id)
    @follower = User.find(mail_data.follower_id)
    @comment = Comment.find mail_data.comment_id
 
    set_locale @follower
    mail :to => @follower.email, :subject => _('The charity "' ) + @charity.name + _('" has a new comment')
  end

  def charity_commented_for_charity(mail_data)
    @charity = Charity.find(mail_data.charity_id)
    @comment = Comment.find mail_data.comment_id
 
    set_locale @charity
    mail :to => @charity.email, :subject => _('The charity "' ) + @charity.name + _('" has a new comment')
  end

  def funds_completed_for_charity(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @charity = User.find(mail_data.charity_id)

    set_locale @charity
    mail :to => @charity.email, :subject => _('The cause "' ) + @cause.name + _('" from your charity is fully funded')
  end

  def funds_completed_for_follower(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)

    set_locale @follower
    mail :to => @follower.email, :subject => _('The cause "' ) + @cause.name + _('"is fully funded')
  end

  def news_created_to_cause(mail_data)
    @cause = Cause.find(mail_data.cause_id)
    @follower = User.find(mail_data.follower_id)
    @new = News.find(mail_data.news_id)

    set_locale @follower
    mail :to => @follower.email, :subject => _('The cause "') + @cause.name + _('" has news')
  end

  def news_created_to_charity(mail_data)
    @charity = Charity.find(mail_data.charity_id)
    @follower = User.find(mail_data.follower_id)
    @new = News.find(mail_data.news_id)

    set_locale @follower
    mail :to => @follower.email, :subject => _('The charity "') + @charity.name + _('" has news')
  end
  
  private 
  
  def set_locale(user)
    I18n.locale = user.preferred_language if Language.by_id(user.preferred_language)
  end
end
