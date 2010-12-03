require 'test_helper'

class ExpenseCategoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "default order is name" do
    z = ExpenseCategory.make :name => 'z'
    a = ExpenseCategory.make :name => 'a'
    
    assert_equal [a,z], ExpenseCategory.all
  end
end
