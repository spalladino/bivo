ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'blueprints'
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  setup { Sham.reset }
  # Add more helper methods to be used by all tests here...
  def assert_save(obj)
    assert obj.save, "could not save "+obj.class.name+" because: "+obj.errors.to_s
  end
end
