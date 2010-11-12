ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'blueprints'

class ActiveSupport::TestCase
  setup { Sham.reset }

  def assert_save(obj)
    assert obj.save, "Could not save #{obj.class.name} because: #{obj.errors.to_s}"
  end

  def assert_equal_unordered(list1, list2, msg=nil)
    assert_equal list1.sort, list2.sort, msg
  end

  def assert_movement(amount, balance, movement)
    assert_equal amount.to_d, movement.amount
    assert_equal balance.to_d, movement.balance
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

  def create_charity_and_sign_in
    user = Charity.make
    sign_in user
    return user
  end

  def create_admin_and_sign_in
    user = Admin.make
    sign_in user
    return user
  end

  def create_incremental_voted_causes(count=25, attributes={})
    (1..count).each { |i| Cause.make_with_votes attributes.merge({:votes_count => i, :status => :active}) }
  end

end

