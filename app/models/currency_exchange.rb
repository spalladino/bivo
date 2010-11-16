require 'money'
require 'money/bank/google_currency'

class CurrencyExchange
  include Singleton

  def get_conversion_rate(value, currency_from, currency_to)
    begin
      value.to_money(currency_from).exchange_to(currency_to)
    rescue
      raise Exception.new("google finance service is unavailable")
    end
  end
end
