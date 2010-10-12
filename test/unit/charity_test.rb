require 'test_helper'

class CharityTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "type is Charity" do
    user = Charity.make
    assert_equal user.type, "Charity"
  end
end