require 'test_helper'

class FollowTest < ActiveSupport::TestCase
  
  test "should send an email to the charity who created the cause being followed" do
    PendingMail.delete_all

    Follow.create({
      :user  => PersonalUser.make,
      :cause => Cause.make
    })

    assert PendingMail.where(:method => :cause_being_followed).count >= 1
  end
  
  test "should send an internationalized email to the charity who created the cause being followed" do
    PendingMail.delete_all

    Follow.create({
      :user  => PersonalUser.make,
      :cause => Cause.make
    })

    assert PendingMail.where(:method => :cause_being_followed).count >= 1
  end
  
end
