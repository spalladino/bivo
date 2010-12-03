require 'test_helper'

class FollowTest < ActiveSupport::TestCase
  test "should send an email to the charity who created the cause being followed" do
    Follow.create({
      :user  => PersonalUser.make,
      :cause => Cause.make  
    })

    assert_equal PendingMail.where(:method => :cause_being_followed).count, 1
    assert_equal PendingMail.where("method != ?", :cause_being_followed).count, 0
  end
end
