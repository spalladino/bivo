require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get edit_user" do
    get :edit_user
    assert_response :success
  end

end
