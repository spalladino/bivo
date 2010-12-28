require 'test_helper'

class MailerTest < ActionMailer::TestCase

  test 'should send cause being followed email' do
    charity = Charity.make
    cause = Cause.make :charity => charity
    user = PersonalUser.make
    
    assert_mails_sent_to charity.email do
      Follow.create :cause => cause, :user => user
    end    
  end
  
  test 'should send charity being followed email' do
    charity = Charity.make
    user = PersonalUser.make
    
    assert_mails_sent_to charity.email do
      CharityFollow.create :charity => charity, :user => user
    end
  end

  test 'should send cause status changed emails' do
    charity = Charity.make
    cause = Cause.make :charity => charity, :status => :active

    assert_mails_sent_to charity.email do
      cause.status = :raising_funds
      cause.save!
    end
  end

  test 'should send cause status changed for followers emails' do
    charity = Charity.make
    cause = Cause.make :status => :active, :charity => charity
    user1 = PersonalUser.make
    user2 = PersonalUser.make
    non_follower = PersonalUser.make    
    
    Follow.create :cause => cause, :user => user1
    Follow.create :cause => cause, :user => user2
    
    assert_mails_sent_to user1.email, user2.email, charity.email do    
      cause.status = :raising_funds
      cause.save!
    end
    
  end

  test 'should send cause commented emails' do
    charity = Charity.make
    cause = Cause.make :status => :active, :charity => charity
    follower_user_1 = PersonalUser.make
    follower_user_2 = PersonalUser.make
    commenting_follower_user = PersonalUser.make
    non_follower_user = PersonalUser.make
    
    [follower_user_1, follower_user_2, commenting_follower_user].each do |user|
      Follow.create :cause => cause, :user => user
    end

    assert_mails_sent_to follower_user_1.email, follower_user_2.email, charity.email do
      Comment.build_from(cause, commenting_follower_user.id, "Hello world").save!
    end
    
  end

  test 'should send charity commented' do
    charity = Charity.make
    follower_user_1 = PersonalUser.make
    follower_user_2 = PersonalUser.make
    commenting_follower_user = PersonalUser.make
    non_follower_user = PersonalUser.make
    
    [follower_user_1, follower_user_2, commenting_follower_user].each do |user|
      CharityFollow.create :charity => charity, :user => user
    end

    assert_mails_sent_to follower_user_1.email, follower_user_2.email, charity.email do
      Comment.build_from(charity, commenting_follower_user.id, "Hello world").save!
    end
    
  end
  
  test 'should send charity commented itself to followers only' do
    charity = Charity.make
    follower_user_1 = PersonalUser.make
    follower_user_2 = PersonalUser.make
    non_follower_user = PersonalUser.make
    
    [follower_user_1, follower_user_2].each do |user|
      CharityFollow.create :charity => charity, :user => user
    end

    assert_mails_sent_to follower_user_1.email, follower_user_2.email do
      Comment.build_from(charity, charity.id, "Hello world").save!
    end
    
  end

  test 'should send funds completed emails' do
    charity = Charity.make
    cause = Cause.make :status => :active, :charity => charity
    user1 = PersonalUser.make
    user2 = PersonalUser.make
    non_follower = PersonalUser.make    
    
    Follow.create :cause => cause, :user => user1
    Follow.create :cause => cause, :user => user2
        
    assert_mails_sent_to user1.email, user2.email, charity.email do
      cause.status = :raising_funds
      cause.save!
    end
    
  end

  test 'should send cause news created emails' do
    charity = Charity.make
    cause = Cause.make :charity => charity
    
    user1 = PersonalUser.make
    user2 = PersonalUser.make
    non_follower = PersonalUser.make
    
    Follow.create :cause => cause, :user => user1
    Follow.create :cause => cause, :user => user2
    
    assert_mails_sent_to user1.email, user2.email do
      News.create :newsable => cause, :body => "Hello world"    
    end    
  end

  test 'should send charity news created emails' do
    charity = Charity.make
    
    user1 = PersonalUser.make
    user2 = PersonalUser.make
    non_follower = PersonalUser.make
    
    CharityFollow.create :charity => charity, :user => user1
    CharityFollow.create :charity => charity, :user => user2
    
    assert_mails_sent_to user1.email, user2.email do
      News.create :newsable => charity, :body => "Hello world"    
    end  
    
  end

end
