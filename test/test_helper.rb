ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'blueprints'

class ActiveSupport::TestCase
  setup { Sham.reset }

  def assert_save(obj)
    assert obj.save, "Could not save #{obj.class.name} because: #{obj.errors.to_s}"
  end
  
  def assert_equal_unordered(list1, list2)
    assert_equal list1.sort, list2.sort
  end

end

class ActionController::TestCase
  include Devise::TestHelpers

  setup { Sham.reset }

  def create_and_sign_in
    user = PersonalUser.make
    sign_in user
    return user
  end
  
  def create_incremental_voted_causes(count=25, attributes={})
    (1..count).each { |i| Cause.make_with_votes attributes.merge({:votes_count => i, :status => :active}) }
  end

end

