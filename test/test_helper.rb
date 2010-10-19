ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'blueprints'

class ActiveSupport::TestCase
  setup { Sham.reset }

  def assert_save(obj)
    assert obj.save, "Could not save #{obj.class.name} because: #{obj.errors.to_s}"
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

end

