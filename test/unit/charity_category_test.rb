require 'test_helper'

class CharityCategoryTest < ActiveSupport::TestCase
  
  test "get categories sorted by charities count" do
    categories = CharityCategory.make_many 3
    categories.each_with_index do |categ, index|
      Charity.make_many index+2, :charity_category => categ
    end
    
    assert_equal CharityCategory.sorted_by_charities_count.map(&:id), categories.reverse.map(&:id)
    assert_equal 4, CharityCategory.sorted_by_charities_count.first.charities_count.to_i
  end
end
