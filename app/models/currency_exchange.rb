require 'money'
require 'money/bank/google_currency'

class CurrencyExchange
  include Singleton

  def get_conversion_rate(value, currency_from, currency_to)
    begin
      value.to_money(currency_from).exchange_to(currency_to)
    rescue
      raise Exception.new("cant be converted to the selected currency right know. Please try again later.")
    end
  end
end
