require 'test_helper'

class PhotoItemTest < ActiveSupport::TestCase

  test "responds to kind" do
    assert_equal :photo, PhotoItem.new.kind
  end

end
