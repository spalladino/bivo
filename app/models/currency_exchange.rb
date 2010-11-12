require 'money'
require 'money/bank/google_currency'

class CurrencyExchange
  def self.get_conversion_rate(value, currency_from, currency_to)
    value.to_money(currency_from).exchange_to(currency_to)
  end
end
