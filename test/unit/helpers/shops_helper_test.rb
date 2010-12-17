require 'test_helper'

class ShopsHelperTest < ActionView::TestCase

  test "should add http protocol to uri" do
    assert_equal 'http://example.com', to_absolute_url('example.com')
  end
  
  test "should keep http protocol in uri" do
    assert_equal 'http://example.com', to_absolute_url('http://example.com')
  end
  
  test "should keep other protocol in uri" do
    assert_equal 'ftp://example.com', to_absolute_url('ftp://example.com')
  end
  
  test "should keep path when adding protocol to uri" do
    assert_equal 'http://example.com/foobar', to_absolute_url('example.com/foobar')
  end

end
