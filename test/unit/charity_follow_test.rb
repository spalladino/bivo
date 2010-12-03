require 'test_helper'

class CharityFollowTest < ActiveSupport::TestCase
  test "should send an email to the charity if it has a new follower" do
    CharityFollow.create({
      :charity => Charity.create,
      :user    => PersonalUser.create
    })

    assert_equal PendingMail.where(:method => :charity_being_followed).count, 1
    assert_equal PendingMail.where("method != ?", :charity_being_followed).count, 0
  end
end
