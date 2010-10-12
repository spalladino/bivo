require 'test_helper'

class CauseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "new category has inactive status" do
    cause = Cause.make
    assert_equal cause.status, :inactive
  end
end
