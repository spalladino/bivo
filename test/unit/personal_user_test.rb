require 'test_helper'

class PersonalUserTest < ActiveSupport::TestCase

  test "insert two users with no nicknames" do
    
    user = PersonalUser.make_unsaved
    assert_save user
    
    user = PersonalUser.make_unsaved
    assert_save user
    
  end
  
  test "insert two users with different nicknames" do
    
    user = PersonalUser.make_unsaved :nickname => "p1"
    assert_save user
    
    user = PersonalUser.make_unsaved :nickname => "p2"
    assert_save user
    
  end
  
  test "cannot insert two users same nicknames case insensitive" do
    
    user = PersonalUser.make_unsaved :nickname => "p"
    assert_save user
    
    user = PersonalUser.make_unsaved :nickname => "P"
    assert !user.save, "should not be able to save"
    
  end
  
  test "first name required" do
    
    user = PersonalUser.make_unsaved :first_name => ""
    assert !user.save, "should not be able to save"
    
  end
  
  test "last name required" do
    
    user = PersonalUser.make_unsaved :last_name => ""
    assert !user.save, "should not be able to save"
    
  end
  
  test "type is personal user" do
    user = PersonalUser.make
    assert_equal user.type, "PersonalUser"
  end
end