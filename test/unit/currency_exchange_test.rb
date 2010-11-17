require 'test_helper'
require 'money'

class CurrencyExchangeTest < ActiveSupport::TestCase
  test "should raise an exception if google service is not working" do
    Money.default_bank.stubs(:get_rate).raises Exception.new

    assert_raise Exception do
      CurrencyExchange.instance.get_conversion_rate(2, :USD, :EUR)
    end


  end

  test "should get conversion rate from google" do
    assert_nothing_raised do
      CurrencyExchange.instance.get_conversion_rate(2, :USD, :EUR)
    end
  end
end
