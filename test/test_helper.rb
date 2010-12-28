ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'blueprints'
require 'watir-webdriver'

class ActiveSupport::TestCase
  setup { Sham.reset }

  def assert_save(obj)
    assert obj.save, "Could not save #{obj.class.name} because: #{obj.errors.to_s}"
  end

  def assert_equal_unordered(list1, list2, msg=nil)
    assert_equal list1.sort, list2.sort, msg
  end

  def assert_movement(amount, balance, movement)
    assert_not_nil movement, "movement should not be nil"
    assert_equal amount.to_d, movement.amount
    assert_equal balance.to_d, movement.balance
  end
end

class ActionController::TestCase
  include Devise::TestHelpers

  setup do 
    Sham.reset 
    $-v= nil
  end

  def create_and_sign_in
    user = PersonalUser.make
    sign_in user
    return user
  end

  def create_charity_and_sign_in(attributes={})
    user = Charity.make attributes
    sign_in user
    return user
  end

  def create_admin_and_sign_in
    user = Admin.make
    sign_in user
    return user
  end

  def create_incremental_voted_causes(count=25, attributes={})
    (1..count).each { |i| Cause.make_with_votes attributes.merge({:votes_count => i, :status => :active}) }
  end

  def set_locale(locale)
    session[:locale] = locale
  end

end

class ActionMailer::TestCase

  def clear_pending_mails
    ActionMailer::Base.deliveries.clear
    PendingMail.delete_all
    
    assert_equal 0, PendingMail.count
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  def assert_mail_sent_to(recipient)
    MailsProcessor.instance.process
    mail = ActionMailer::Base.deliveries.first
    assert_not_nil mail
    assert_equal recipient, mail.to.first
  end

  def assert_mails_sent_to(*recipients)
    if block_given?
      clear_pending_mails
      yield
    end
    
    sent,failed,errs = MailsProcessor.instance.process
    throw errs.first if errs.any?
    
    actual_recipients = ActionMailer::Base.deliveries.map{|m| m.to.first}
    assert_equal recipients.sort, actual_recipients.sort
  end


end
