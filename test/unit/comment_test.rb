require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test 'should send an email to the followers and charity when commenting a cause' do
    cause = Cause.make

    FollowObserver.instance.stubs(:after_create)

    3.times do
      Follow.create ({
        :user  => PersonalUser.make,
        :cause => cause
      })
    end

    new_comment = Comment.build_from(cause, PersonalUser.make.id, "just a comment for testing")
    new_comment.save

    assert_equal PendingMail.where(:method => :cause_commented_for_follower).count, 3
    assert_equal PendingMail.where(:method => :cause_commented_for_charity).count, 1
    assert_equal PendingMail.count, 4
  end

  test 'should send an email to the followers and charity when commenting a charity' do
    charity = Charity.make

    CharityFollowObserver.instance.stubs(:after_create)

    3.times do
      CharityFollow.create ({
        :user    => PersonalUser.make,
        :charity => charity
      })
    end

    new_comment = Comment.build_from(charity, PersonalUser.make.id, "just a comment for testing")
    new_comment.save

    assert_equal PendingMail.where(:method => :charity_commented_for_follower).count, 3
    assert_equal PendingMail.where(:method => :charity_commented_for_charity).count, 1
    assert_equal PendingMail.count, 4
  end
end
