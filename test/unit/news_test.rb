require 'test_helper'

class NewsTest < ActiveSupport::TestCase
  test 'should send an email to the followers when creating a cause news' do
    cause = Cause.make

    FollowObserver.instance.stubs(:after_create)

    3.times do
      Follow.create ({
        :user  => PersonalUser.make,
        :cause => cause
      })
    end

    News.create({
      :body => "testing the news",
      :newsable_id => cause.id,
      :newsable_type => cause.class.to_s
    })

    assert_equal PendingMail.where(:method => :news_created_to_cause).count, 3
    assert_equal PendingMail.count, 3
  end

  test 'should send an email to the followers when creating a charity news' do
    charity = Charity.make

    CharityFollowObserver.instance.stubs(:after_create)

    3.times do
      CharityFollow.create ({
        :user    => PersonalUser.make,
        :charity => charity
      })
    end

    News.create({
      :body => "testing the news",
      :newsable_id => charity.id,
      :newsable_type => charity.class.to_s
    })

    assert_equal PendingMail.where(:method => :news_created_to_charity).count, 3
    assert_equal PendingMail.count, 3
  end
end
