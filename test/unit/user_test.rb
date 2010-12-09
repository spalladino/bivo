require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "logical deleted user should not appear" do
    user1 = Charity.make(:status => :deleted)
    user2 = PersonalUser.make(:status => :deleted)

    assert_equal 0, User.all.count
    assert_equal 2, User.with_exclusive_scope.all.count
  end
end

