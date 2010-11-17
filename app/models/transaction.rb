class Transaction < ActiveRecord::Base
  DefaultCurrency = :GBP
  belongs_to :user
  attr_accessor :currency

  validates_numericality_of :amount
  
  validates_presence_of :user_id, :amount, :transaction_date, :type
  
  validates_length_of :description, :maximum => 255
  
  validates_inclusion_of :type, :in => %w(Income Expense), :message => "%{value} should be either Income or Expense"

  validate :check_convertion_to_currency

  def check_convertion_to_currency
    begin
      if (currency != DefaultCurrency)
        self.amount = CurrencyExchange.instance.get_conversion_rate(
          amount, currency, DefaultCurrency
        )
      end
    rescue Exception => e
      errors.add(:currency, e.message)
    end
  end
end
