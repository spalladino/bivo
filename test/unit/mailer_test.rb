require 'test_helper'

class MailerTest < ActionMailer::TestCase

  test 'should deliver cause being followed email' do
    charity = Charity.make
    mail_data = {
      :cause_id    => Cause.make(:charity => charity),
      :follower_id => PersonalUser.make
    }.to_struct

    Mailer.cause_being_followed(mail_data).deliver

    assert_mail_sent_to charity.email
  end

  test 'should send cause status changed for charity email' do
    #assert false
  end

  test 'should send cause status changed for follower email' do
    #assert false
  end

  test 'should send cause commented for charity email' do
    #assert false
  end

  test 'should send cause commented for follower email' do
    #assert false
  end

  test 'should send charity commented for charity email' do
    #assert false
  end

  test 'should send charity commented for follower email' do
    #assert false
  end

  test 'should send funds completed for charity email' do
    #assert false
  end

  test 'should send funds completed for follower email' do
    #assert false
  end

  test 'should send news created to cause email' do
    #assert false
  end

  test 'should send news created to charity email' do
    #assert false 
  end
end
