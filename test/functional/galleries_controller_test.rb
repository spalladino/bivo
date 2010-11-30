require 'test_helper'

class GalleriesControllerTest < ActionController::TestCase
  
  def edit_gallery(entity)
    get :edit, :entity_type => entity.class.name, :entity_id => entity.id
  end
  
  test "should be able to edit charity gallery" do
    user = create_charity_and_sign_in
    edit_gallery user
    assert_response :ok
  end
  
  test "should be able to edit cause gallery" do
    user = create_charity_and_sign_in
    cause = Cause.make :charity => user
    edit_gallery cause 
    assert_response :ok
  end
  
  test "should not be able edit others charity gallery" do
    create_and_sign_in
    edit_gallery Charity.make
    assert_response :forbidden
  end

  test "should not be able edit others cause gallery" do
    create_and_sign_in
    edit_gallery Cause.make
    assert_response :forbidden
  end

  test "guest should not be able to edit charity gallery" do
    edit_gallery Charity.make
    assert_response :forbidden
  end

  test "guest should not be able to edit cause gallery" do
    edit_gallery Cause.make
    assert_response :forbidden
  end

end